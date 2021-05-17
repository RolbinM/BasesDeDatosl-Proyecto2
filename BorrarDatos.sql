USE BaseDatosPlanilla

DELETE FROM Usuarios
DBCC CHECKIDENT(Usuarios,RESEED,0)

DELETE FROM Empleados
DBCC CHECKIDENT(Empleados,RESEED,0)

DELETE FROM Departamentos
DELETE FROM TiposDocumentoIdentificacion
DELETE FROM Puestos
