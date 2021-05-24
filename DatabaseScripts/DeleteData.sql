USE BDPlanillaObrera

DELETE FROM Empleado
DBCC CHECKIDENT(Empleado,RESEED,0)

DELETE FROM Usuario
DBCC CHECKIDENT(Usuario,RESEED,0)

DELETE FROM Feriado
DBCC CHECKIDENT(Feriado,RESEED,0)

DELETE FROM dbo.DeduccionObligatoriaPorcentual
DELETE FROM dbo.TipoDeduccion
DELETE FROM dbo.TipoMovimiento
DELETE FROM dbo.TipoJornada
DELETE FROM dbo.Departamento
DELETE FROM dbo.TipoDocumentoIdentidad
DELETE FROM dbo.Puesto



DELETE FROM dbo.Errores