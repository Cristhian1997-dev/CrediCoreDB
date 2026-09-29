# CrediCore - Fase 5
# Módulo web de caja desarollado con Streamlit

import streamlit as st
import pandas as pd
import pyodbc

# Configuración general de la página

#Configuramos el título que aparecerá en la pestaña del navegador y definimos que la aplicación use un ancho centrado.
st.set_page_config(
    page_title="ERP CrediCore",
    layout="centered"
)

# Cargamos las credenciales de forma segura.
SERVER = st.secrets["database"]["server"]
DATABASE = st.secrets["database"]["database"]
USERNAME = st.secrets["database"]["username"]
PASSWORD = st.secrets["database"]["password"]

#Detectamos el driver ODBC que instalamos
drivers_disponibles = pyodbc.drivers()

#Primero intentamos utilizar Driver 18.
if "ODBC Driver 18 for SQL Server" in drivers_disponibles:
    DRIVER = "ODBC Driver 18 for SQL Server"

#Si no existe el 18, intentamos usar 17
elif "ODBC Driver 17 for SQL Server" in drivers_disponibles:
    DRIVER = "ODBC Driver 17 for SQL Server"

# Si Windows no tiene ninguno, detenemos la aplicación.
else:
    st.error(
        "No se encontró ODBC Driver 17 ni 18 para SQL Server."
    )
    st.stop()

#Cadena de conexión a SQL Server
conn_str = (
    f"DRIVER={{{DRIVER}}};"
    f"SERVER={SERVER};"
    f"DATABASE={DATABASE};"
    f"UID={USERNAME};"
    f"PWD={PASSWORD};"
    f"TrustServerCertificate=yes;"
)

#Función para crear una conexión
def obtener_conexion():
    """
    Crea y devuelve una nueva conexión hacia SQL Server.

    autocommit=True es importante en nuestro caso porque
    SP_ProcesarPago ya administra internamente su propia
    transacción mediante:

    BEGIN TRAN
    COMMIT
    ROLLBACK
    """

    return pyodbc.connect(
        conn_str,
        autocommit=True
    )

#Encabezado de la aplicación
st.title("CrediCore - Módulo de Caja")
st.markdown(
    """
    Interfaz conectada directamente al motor transaccional
    de **SQL Server**.
    """
)

#Mostrar la vista segura
st.subheader("Estado de Cuenta")

try:

    # Abrimos una conexión con SQL Server.
    conn = obtener_conexion()

    # IMPORTANTE:
    # No consultamos directamente Clientes ni Creditos.
    #
    # Utilizamos la vista segura creada en Fase 4.
    query = """
        SELECT
            NombreCliente,
            NumeroCredito,
            MarcaVehiculo,
            EstadoCredito,
            SaldoActual
        FROM Operaciones.vw_AtencionAlCliente
        ORDER BY NumeroCredito;
    """

    # Ejecutamos la consulta y convertimos
    # el resultado en un DataFrame de pandas.
    df = pd.read_sql_query(
        query,
        conn
    )

    # Cerramos la conexión después de leer los datos.
    conn.close()

    # Mostramos los datos dentro de Streamlit.
    st.dataframe(
        df,
        use_container_width=True,
        hide_index=True
    )

except Exception as e:

    # Si SQL Server no responde o existe algún problema
    # de autenticación, mostramos el error.
    st.error(
        f"Error de conexión a la base de datos: {e}"
    )


# Línea divisoria visual.
st.divider()

#Formulario para procesar pagos
st.subheader("Procesar Pago de Cuota")

# El formulario agrupa los campos y evita que Streamlit
# ejecute la operación hasta presionar el botón.
with st.form(
    "form_pago",
    clear_on_submit=False
):

    # ID del crédito que pagará el cliente.
    id_credito = st.number_input(
        "Número de Crédito",
        min_value=1,
        step=1
    )

    # Cantidad que desea abonar.
    monto_pago = st.number_input(
        "Monto a Abonar (Q)",
        min_value=0.01,
        step=100.00,
        format="%.2f"
    )

    # Botón que envía el formulario.
    btn_pagar = st.form_submit_button(
        "Ejecutar Transacción"
    )

#Ejecutar el procedimiento almacenado
if btn_pagar:

    try:

        # Abrimos una nueva conexión específicamente
        # para procesar el pago.
        conn = obtener_conexion()

        # Creamos un cursor.
        #
        # El cursor permite enviar instrucciones
        # T-SQL hacia SQL Server.
        cursor = conn.cursor()


        # ==================================================
        # MUY IMPORTANTE: CONSULTA PARAMETRIZADA
        # ==================================================
        #
        # NO hacemos:
        #
        # f"EXEC ... {id_credito} ..."
        #
        # porque estaríamos concatenando valores
        # directamente dentro del SQL.
        #
        # Los signos ? representan parámetros que
        # pyodbc enviará de forma separada y segura.

        cursor.execute(
            """
            EXEC Operaciones.SP_ProcesarPago
                @IdCredito = ?,
                @MontoAbono = ?
            """,
            int(id_credito),
            float(monto_pago)
        )


        # Nuestro procedimiento devuelve:
        #
        # IdCredito
        # NuevoSaldo
        #
        # Recuperamos esa fila.
        resultado = cursor.fetchone()


        # Guardamos el nuevo saldo si el procedimiento
        # devolvió información.
        if resultado:

            nuevo_saldo = resultado[1]

            # Guardamos temporalmente el mensaje para
            # mostrarlo después del rerun.
            st.session_state["pago_exitoso"] = (
                f"Pago procesado correctamente. "
                f"Nuevo saldo: Q{nuevo_saldo:,.2f}"
            )

        else:

            st.session_state["pago_exitoso"] = (
                "Pago procesado correctamente."
            )


        # Cerramos cursor y conexión.
        cursor.close()
        conn.close()


        # Streamlit vuelve a ejecutar la aplicación.
        #
        # Esto hará que la vista se consulte nuevamente
        # y aparezca inmediatamente el nuevo saldo.
        st.rerun()


    except Exception as e:

        # Si SP_ProcesarPago ejecuta THROW,
        # pyodbc recibe exactamente el error enviado
        # por SQL Server.
        #
        # Por ejemplo:
        #
        # "El monto del abono es mayor al saldo actual
        # del credito."

        st.error(
            f"Transacción rechazada por el motor:\n\n{e}"
        )

#Mostrar mensaje después del rerun
if "pago_exitoso" in st.session_state:

    st.success(
        st.session_state["pago_exitoso"]
    )

    # Eliminamos el mensaje para que no aparezca
    # permanentemente en futuras recargas.
    del st.session_state["pago_exitoso"]