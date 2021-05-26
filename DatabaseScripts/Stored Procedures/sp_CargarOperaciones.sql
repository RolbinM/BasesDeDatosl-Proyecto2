USE [BDPlanillaObrera]
GO

/****** Object:  StoredProcedure [dbo].[sp_CargarOperaciones]    Script Date: 24/05/2021 2:16:31 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CargarOperaciones]
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		-- Cargar Datos de Insercion de las jornadas en una tabla temporal
		CREATE TABLE ##Operaciones(
			FechaOperacion DATE
		);

		DECLARE @OutResultCode INT

		SET @OutResultCode = 0;

		BEGIN TRANSACTION CargarOperaciones
			INSERT INTO ##Operaciones
				SELECT
					CAST(operacion.value('@Fecha','VARCHAR(64)') AS DATE) AS FechaOp
				FROM
				(
					SELECT CAST(c AS XML) FROM
					OPENROWSET(
						BULK 'C:\Users\rolbi\Desktop\BasesDeDatosl-Proyecto2\Datos_Tarea2.xml',
						SINGLE_BLOB
					) AS T(c)
				) AS S(C)
				CROSS APPLY c.nodes('Datos/Operacion') AS A(operacion)

		COMMIT TRANSACTION CargarOperaciones

	END TRY
	BEGIN CATCH
		IF @@Trancount>0 
			ROLLBACK TRANSACTION CargarOperaciones;

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


