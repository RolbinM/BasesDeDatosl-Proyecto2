USE [BDPlanillaObrera]
GO

/****** Object:  StoredProcedure [dbo].[sp_CargarInsercionMarcaAsistencia]    Script Date: 24/05/2021 11:18:13 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CargarInsercionMarcaAsistencia]
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		-- Cargar Datos de Insercion de Tipos de Jornada en una tabla temporal
		CREATE TABLE ##InsercionMarcaAsistencia(
		Fecha DATE,
		FechaEntrada DATE,
		HoraEntrada TIME,
		FechaSalida DATE,
		HoraSalida TIME,
		ValorDocumentoIdentidad VARCHAR(32)
		);

		DECLARE @OutResultCode INT

		SET @OutResultCode = 0;

		BEGIN TRANSACTION CargarInsercionMarcaAsistencia
			INSERT INTO ##InsercionMarcaAsistencia
				SELECT
					CAST(marcaAsistencia.value('../@Fecha','VARCHAR(32)') AS DATE) AS Fecha,
					CAST(marcaAsistencia.value('@FechaEntrada','VARCHAR(32)') AS DATE) AS FechaEntrada,
					CAST(marcaAsistencia.value('@FechaEntrada','VARCHAR(32)') AS TIME) AS HoraEntrada,
					CAST(marcaAsistencia.value('@FechaSalida','VARCHAR(32)') AS DATE) AS FechaSalida,
					CAST(marcaAsistencia.value('@FechaSalida','VARCHAR(32)') AS TIME) AS HoraSalida,
					marcaAsistencia.value('@ValorDocumentoIdentidad','VARCHAR(32)') AS ValorDocumentoIdentidad
				FROM
				(
					SELECT CAST(c AS XML) FROM
					OPENROWSET(
						BULK 'C:\Users\rolbi\Desktop\BasesDeDatosl-Proyecto2\Datos_Tarea2.xml',
						SINGLE_BLOB
					) AS T(c)
				) AS S(C)
				CROSS APPLY c.nodes('Datos/Operacion/MarcaDeAsistencia') AS A(marcaAsistencia)

		COMMIT TRANSACTION CargarInsercionMarcaAsistencia

	END TRY
	BEGIN CATCH
		IF @@Trancount>0 
			ROLLBACK TRANSACTION CargarInsercionMarcaAsistencia;

		INSERT INTO dbo.Errores VALUES(
			ERROR_NUMBER(),
			ERROR_STATE(),
			ERROR_SEVERITY(),
			ERROR_PROCEDURE(),
			ERROR_LINE(),
			ERROR_MESSAGE(),
			GETDATE()
		)

		SET @OutResultCode = 501;				-- No se inserto en la tabla

	END CATCH

	SELECT @OutResultCode


	SET NOCOUNT OFF
END

GO


