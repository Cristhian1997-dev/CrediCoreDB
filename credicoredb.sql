CREATE DATABASE CrediCoreDB;
USE CrediCoreDB;

CREATE SCHEMA Operaciones;
CREATE SCHEMA Garantias;

/* Primera tabla registros de clientes, restricción que no permita ingresar 2 DPI iguales */
CREATE TABLE Operaciones.Clientes(
	IdCliente INT IDENTITY(1,1) NOT NULL,
	Nombre VARCHAR(50) NOT NULL,
	Apellido VARCHAR(50) NOT NULL,
	DPI VARCHAR(50) NOT  NULL,
	Telefono VARCHAR(25) NULL,
	Correo VARCHAR(50) NOT NULL,
	
	CONSTRAINT PK_Clientes_IdCLiente
		PRIMARY KEY (IdCliente),
	/* Se le coloca un UNIQUE al Documento Personal para que no deje ingresar 2 datos iguales */
	CONSTRAINT UQ_CLientes_DocumentoPersonal
		UNIQUE (DPI)
	);

/* 
 * Segunda tabla de registros de vehiculos, restricción no se aceptan vehiculos menores del 2011,
 * número de placa y chasis son unicos no se aceptan los mismos números y IdVehiculos es nuestra llave primaria.
 */
CREATE TABLE Garantias.Vehiculos(
	IdVehiculo INT IDENTITY(1,1) NOT NULL,
	Modelo VARCHAR(50) NOT NULL,
	Marca VARCHAR(80) NOT NULL,
	NumeroPlaca VARCHAR(25) NOT NULL,
	NumeroChasis VARCHAR(50) NOT NULL,
	AnioFabricacion SMALLINT NOT NULL,
	Color VARCHAR(40) NULL,
	NumeroTituloPropiedad VARCHAR(80) NOT NULL,
	
	CONSTRAINT CK_Vehiculos_AnioFabricacion
		CHECK (AnioFabricacion >= 2011),
	CONSTRAINT UQ_Vehiculos_NumeroPlaca
		UNIQUE (NumeroPlaca),
	CONSTRAINT UQ_Vehiculos_NumeroChasis
		UNIQUE (NumeroChasis)
);

ALTER TABLE Garantias.Vehiculos
	ADD CONSTRAINT PK_Vehiculos_IdVehiculo
	PRIMARY KEY (IdVehiculo);

/*
* Tercera tabla de registro de Creditos, restricción: la tasa de interes jamás puede ser negativa y el monto debe ser mayor a Q1,000
* restricción inquebrantable, todo préstamo insertado debe tener un campo estado y su valor predeterminado debe ser 'Activo', y un campo
* FechaDesembolso que capture automaticamente la fecha y hora exacta del servidor.
*/
CREATE TABLE Operaciones.Creditos(
	IdCredito INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	IdCliente INT NOT NULL,
	IdVehiculo INT NOT NULL,
	MontoCapitalOtorgado DECIMAL(18,2) NOT NULL,
	TasaInteresMensual DECIMAL(5,2) NOT NULL,
	Estado VARCHAR(20) NOT NULL
		CONSTRAINT DF_Creditos_Estado
		DEFAULT ('Activo'),
	FechaDesembolso DATETIME NOT NULL
		CONSTRAINT DF_Creditos_FechaDesembolso
		DEFAULT (GETDATE()),
		
	/* Restricciones */
	CONSTRAINT CK_Creditos_MontoCapitalOtorgado
		CHECK (MontoCapitalOtorgado > 1000),
	CONSTRAINT CK_Creditos_TasaInteresMensual
		CHECK (TasaInteresMensual >= 0)
);
