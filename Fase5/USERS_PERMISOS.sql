USE CrediCoreDB;

//Verificamos que usuarios tenemos
SELECT 
	name AS Usuario,
	type_desc AS Tipo
FROM sys.database_principals
WHERE type_desc IN 
(
	'SQL_USER',
	'WINDOWS_USER'
)
AND name NOT IN
(
	'dbo',
	'guest',
	'INFORMATION_SCHEMA',
	'sys'
);

-- Nos movemos a master porque el LOGIN pertenece al servidor,
-- no únicamente a CrediCoreDB.
USE master;

-- Creamos una cuenta que podrá iniciar sesión en SQL Server.
CREATE LOGIN CrediCoreApp
WITH PASSWORD = 'JUNTADIRECTIVACORREO';

--Creamos el usuario dentro de CrediCoreDB y lo relacionamos con el LOGIN creado anteriormente
CREATE USER CrediCoreApp
FOR LOGIN CrediCoreApp;

--Permitimos consultar únicamente la vista que oculta (DPI, teléfono, chasis e información sensible).
GRANT SELECT
ON OBJECT::Operaciones.vw_AtencionAlCliente
TO CrediCoreAPP;

--Permitimos ejecutar el procedimiento almacenado que contiene toda la lógica transaccional de pagos.
GRANT EXECUTE
ON OBJECT::Operaciones.SP_ProcesarPago
TO CrediCoreApp;

--Coprobamos que el USER fue creado dentro de CrediCoreDB
SELECT 
	name AS Usuario,
	type_desc AS Tipo
FROM sys.database_principals
WHERE name = 'CrediCoreApp';

-- Comprobamos que existe también la cuenta a nivel servidor.
SELECT
    name AS LoginSQL,
    type_desc AS Tipo
FROM sys.server_principals
WHERE name = 'CrediCoreApp';

