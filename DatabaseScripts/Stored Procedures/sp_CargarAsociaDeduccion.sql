USE [BDPlanillaObrera]
GO

/****** Object:  StoredProcedure [dbo].[sp_CargarAsociaDeduccion]    Script Date: 24/05/2021 1:58:22 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CargarAsociaDeduccion]
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		-- Cargar Datos de Insercion de las jornadas en una tabla temporal
		CREATE TABLE ##InsercionAsociaDeduccion(
		Fecha DATE,
		IdDeduccion INT,
		Monto DECIMAL(18, 3),
		ValorDocumentoIdentidad VARCHAR(32)
		);

		DECLARE @OutResultCode INT

		SET @OutResultCode = 0;

		BEGIN TRANSACTION CargarAsociaDeduccion
			INSERT INTO ##InsercionAsociaDeduccion
				SELECT
					CAST(asociaDeduccion.value('../@Fecha','VARCHAR(32)') AS DATE) AS Fecha,
					asociaDeduccion.value('@IdDeduccion','INT') AS IdDeduccion,
					asociaDeduccion.value('@Monto','DECIMAL(18, 3)') AS Monto,
					asociaDeduccion.value('@ValorDocumentoIdentidad','VARCHAR(32)') AS ValorDocumentoIdentidad
				FROM
				(
					SELECT CAST(c AS XML) FROM
					OPENROWSET(
						BULK 'C:\Users\rolbi\Desktop\BasesDeDatosl-Proyecto2\Datos_Tarea2.xml',
						SINGLE_BLOB
					) AS T(c)
				) AS S(C)
				CROSS APPLY c.nodes('Datos/Operacion/AsociaEmpleadoConDeduccion') AS A(asociaDeduccion)

		COMMIT TRANSACTION CargarAsociaDeduccion

	END TRY
	BEGIN CATCH
		IF @@Trancount>0 
			ROLLBACK TRANSACTION CargarAsociaDeduccion;

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


