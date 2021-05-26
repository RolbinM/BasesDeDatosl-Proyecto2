USE [BDPlanillaObrera]
GO

/****** Object:  StoredProcedure [dbo].[sp_CargarInsercionTipoJornada]    Script Date: 24/05/2021 9:08:29 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CargarInsercionTipoJornada]
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		-- Cargar Datos de Insercion de Tipos de Jornada en una tabla temporal
		CREATE TABLE ##InsercionTipoJornada(
		Fecha DATE,
		Id INT,
		ValorDocumentoIdentidad VARCHAR(32)
		);

		DECLARE @OutResultCode INT

		SET @OutResultCode = 0;

		BEGIN TRANSACTION CargarInsercionTipoJornada
			INSERT INTO ##InsercionTipoJornada
				SELECT
					CAST(tipoJornada.value('../@Fecha','VARCHAR(64)') AS DATE) AS Fecha,
					tipoJornada.value('@IdJornada','INT') AS Id,
					tipoJornada.value('@ValorDocumentoIdentidad','VARCHAR(32)') AS ValorDocumentoIdentidad
				FROM
				(
					SELECT CAST(c AS XML) FROM
					OPENROWSET(
						BULK 'C:\Users\rolbi\Desktop\BasesDeDatosl-Proyecto2\Datos_Tarea2.xml',
						SINGLE_BLOB
					) AS T(c)
				) AS S(C)
				CROSS APPLY c.nodes('Datos/Operacion/TipoDeJornadaProximaSemana') AS A(tipoJornada)

		COMMIT TRANSACTION CargarInsercionTipoJornada

	END TRY
	BEGIN CATCH
		IF @@Trancount>0 
			ROLLBACK TRANSACTION CargarInsercionTipoJornada;

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


