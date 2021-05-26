-- Cargar XML y verificar datos
EXEC sp_CargarXML

SELECT * FROM dbo.Departamento
SELECT * FROM dbo.Puesto

SELECT * FROM dbo.TipoDocumentoIdentidad
SELECT * FROM dbo.TipoJornada

SELECT * FROM dbo.TipoMovimiento
SELECT * FROM dbo.Feriado

SELECT * FROM dbo.TipoDeduccion
SELECT * FROM dbo.DeduccionObligatoriaPorcentual

SELECT * FROM dbo.Empleado
SELECT * FROM dbo.Usuario

SELECT * FROM dbo.MesPlanilla
SELECT * FROM dbo.SemanaPlanilla

SELECT * FROM dbo.Jornada
SELECT * FROM dbo.MarcaAsistencia
SELECT * FROM dbo.DeduccionXEmpleado