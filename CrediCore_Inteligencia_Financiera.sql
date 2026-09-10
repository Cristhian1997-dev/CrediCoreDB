USE CrediCoreDB;

-- Antes de hacer el BULK INSER verificamos que Operaciones.Creditos este o quede vacio.
-- TRUNCATE TABLE Operaciones.Creditos;

-- Ahora vacia la tabla podemos hacer el BULK INSERT
BULK INSERT Operaciones.Creditos
FROM '/var/opt/mssql/import/CrediCore_Creditos_2000.txt'
WITH
(
	DATAFILETYPE = 'char',
	FIELDTERMINATOR = '|',
	ROWTERMINATOR = '0x0a',
	CHECK_CONSTRAINTS
);

-- Verificamos que los registros esten ingresados
SELECT COUNT(*) AS TotalCreditos
FROM Operaciones.Creditos;

SELECT TOP 10 *
FROM Operaciones.Creditos;

SELECT 
	MIN(IdCredito) AS PrimerId,
	MAX(IdCredito) AS UltimoId
FROM Operaciones.Creditos;

-- Cuanto es el Total de Capital Prestado
SELECT 
	Estado,
	SUM(MontoCapitalOtorgado) AS TotalCapitalOtorgado,
	AVG(TasaInteresMensual) AS PromedioTasaInteres
FROM Operaciones.Creditos
GROUP BY Estado;

-- Cúantos Prestamos hay agrupando por la "Marca del Vehículo".
SELECT 
	V.Marca,
	COUNT(*) AS CantidadPrestamos
FROM Operaciones.Creditos AS C
INNER JOIN Garantias.Vehiculos AS V
	ON C.IdVehiculo = V.IdVehiculo
GROUP BY V.Marca 
HAVING COUNT(*) > 50;

-- Devover el préstamo de mayor valor historico y el menor.
SELECT
	MAX(MontoCapitalOtorgado) AS MayorValorHistorico,
	MIN(MontoCapitalOtorgado) AS MenorValorHistorico
FROM Operaciones.Creditos;