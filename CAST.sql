INSERT INTO TiposJornada (Id, Nombre, HoraEntrada, HoraSalida, Activo)
VALUES (
2,
'Diurna',
CAST ('12:05 am' AS TIME),
CAST ('12:05 pm' AS TIME),
1
);

select * from TiposJornada