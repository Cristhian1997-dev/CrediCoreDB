USE CrediCoreDB;

--Comprobar cliente huéranos
--Anteriormente creamos 2,000 creditos,
--Por lo que podemos tener IdCliente = 9999

SELECT COUNT(*) AS CreditosConClienteInexistente
FROM Operaciones.Creditos AS C
LEFT JOIN Operaciones.Clientes AS CL
	ON C.IdCliente = CL.IdCliente
WHERE CL.IdCliente IS NULL;

--Comprobar vehiculos huérfanos
SELECT COUNT(*) AS CreditosConVehiculosInexistentes
FROM Operaciones.Creditos AS C
LEFT JOIN Garantias.Vehiculos AS V
	ON C.IdVehiculo = V.IdVehiculo
WHERE V.IdVehiculo IS NULL;

--Primera relación Créditos y Clientes
ALTER TABLE Operaciones.Creditos
ADD CONSTRAINT FK_Creditos_Clientes
FOREIGN KEY (IdCliente) --Le decimos, el valor que aparezca en Credito.IdCliente debe existir en Cliente.IdCliente
REFERENCES Operaciones.Clientes(IdCliente)
ON DELETE NO ACTION 
ON UPDATE NO ACTION;

--Segunda relación Créditos y Vehiculos
ALTER TABLE Operaciones.Creditos
ADD CONSTRAINT FK_Creditos_Vehiculos
FOREIGN KEY (IdVehiculo) --Le decimos, el valor que parezca en Credito.IdVehiculo debe existir en Vehiculo.IdVeiculo.
REFERENCES Garantias.Vehiculos(IdVehiculo)
ON DELETE NO ACTION -- Si alguien intenta eliminar un registro de la tabla padre que todavía está siendo usada por la hija no la elimina.
ON UPDATE NO ACTION; -- No permite cambiar o hacerle UPDATE a nuestro IdVehiculo 

SELECT TOP 5
	CL.IdCliente,
	CL.Nombre,
	CL.Apellido,
	COUNT(C.IdCredito) AS CantidadCreditos --Cuenta cuántos créditos tiene cada cliente.
FROM Operaciones.Clientes As CL 
INNER JOIN Operaciones.Creditos AS C --Une solamente clientes que tengan coicidencia con algún crédito.
	ON CL.IdCliente = C.IdCliente 
GROUP BY --Agrupa los créditos por cliente para poder contarlos.
	CL.IdCliente,
	CL.Nombre,
	CL.Apellido
ORDER BY CantidadCreditos DESC;

--Destrucción
DELETE FROM Operaciones.Clientes
WHERE IdCliente = 261;

--Reporte Gerencial
SELECT 
	CL.Nombre,
	CL.Telefono,
	V.Marca,
	V.NumeroPlaca,
	C.MontoCapitalOtorgado,
	C.Estado
FROM Operaciones.Creditos AS C --Empieza desde la tabla Créditos.
INNER JOIN Operaciones.Clientes AS CL
	ON C.IdCliente  = CL.IdCliente -- Busca el cliente cuyo IdCliente coicida con el IdCliente de crédito.
INNER JOIN Garantias.Vehiculos AS V
	ON C.IdVehiculo = V.IdVehiculo; -- Busca el vehiculo cuyo IdCliente coincida con el IdCliente de vehiculo.

-- Consulta con LEFT JOIN = datos NULL
SELECT
	CL.Nombre AS NombreCliente,
	CL.Telefono,
	C.IdCredito
FROM Operaciones.Clientes AS CL
LEFT JOIN Operaciones.Creditos AS C
	ON CL.IdCliente = C.IdCliente
WHERE C.IdCliente IS NULL;

-- Filtro dinámico
SELECT
	CL.Nombre AS NombreCliente,
	C.MontoCapitalOtorgado
FROM Operaciones.Creditos AS C
INNER JOIN Operaciones.Clientes AS CL
	ON C.IdCliente = CL.IdCliente
WHERE C.MontoCapitalOtorgado >
( --Sub Consulta:
	SELECT AVG(MontoCapitalOtorgado)
	FROM Operaciones.Creditos
);

SELECT AVG(MontoCapitalOtorgado)
FROM Operaciones.Creditos;
