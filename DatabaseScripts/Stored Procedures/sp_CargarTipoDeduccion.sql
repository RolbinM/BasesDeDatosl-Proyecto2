USE [BDPlanillaObrera]
GO

/****** Object:  StoredProcedure [dbo].[sp_CargarTipoDeduccion]    Script Date: 23/05/2021 7:12:59 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CargarTipoDeduccion]
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		-- Cargar Datos de TipoDeduccion

		DECLARE @OutResultCode INT

		SET @OutResultCode = 0;

		BEGIN TRANSACTION CargarTipoDeduccion
			DECLARE @count INT;						-- Contador para recorrer la tabla temporal

			CREATE TABLE #TiposDeduccion(			-- Tabla temporal
				Id INT, 
				Nombre VARCHAR(64),
				Obligatorio VARCHAR(2),
				Porcentual VARCHAR(2),
				Valor DECIMAL(18, 3)
			);
			INSERT INTO #TiposDeduccion
				SELECT
					tipDeduccion.value('@Id','INT') AS Id,
					tipDeduccion.value('@Nombre','VARCHAR(64)') AS Nombre,
					tipDeduccion.value('@Obligatorio','VARCHAR(2)') AS EsObligatorio,
					tipDeduccion.value('@Porcentual','VARCHAR(2)') AS EsPorcentual,
					tipDeduccion.value('@Valor','DECIMAL(18, 3)') AS Valor
				FROM
				(
					SELECT CAST(c AS XML) FROM
					OPENROWSET(
						BULK 'C:\Users\rolbi\Desktop\BasesDeDatosl-Proyecto2\Datos_Tarea2.xml',
						SINGLE_BLOB
					) AS T(c)
				) AS S(C)
				CROSS APPLY c.nodes('Datos/Catalogos/Deducciones/TipoDeDeduccion') AS A(tipDeduccion)

			SELECT @count = COUNT(*) FROM #TiposDeduccion

			WHILE @count > 0
			BEGIN
				DECLARE @Id INT = (SELECT TOP(1) Id FROM #TiposDeduccion);
				DECLARE @Nombre VARCHAR(64) = (SELECT TOP(1) Nombre FROM #TiposDeduccion);
				DECLARE @Obligatorio VARCHAR(2) = (SELECT TOP(1) Obligatorio FROM #TiposDeduccion);
				DECLARE @Porcentual VARCHAR(2) = (SELECT TOP(1) Porcentual FROM #TiposDeduccion);
				DECLARE @Valor DECIMAL(18,3) = (SELECT TOP(1) Valor FROM #TiposDeduccion);

				DECLARE @ObligatorioBit BIT, @PorcentualBit BIT
				SET @ObligatorioBit = 0
				SET @PorcentualBit = 0

				IF @Porcentual = 'Si'
				BEGIN
					SET @PorcentualBit = 1
				END
				IF @Obligatorio = 'Si'
				BEGIN
					SET @ObligatorioBit = 1
				END

				INSERT INTO dbo.TipoDeduccion 
				VALUES(
					@Id,
					@Nombre,
					@ObligatorioBit,
					@PorcentualBit
				)

				IF @Obligatorio = 'Si' AND @Porcentual = 'Si'
				BEGIN
					INSERT INTO dbo.DeduccionObligatoriaPorcentual
					VALUES(
						@Id,
						@Valor
					)
				END

				DELETE TOP (1) FROM #TiposDeduccion
				SELECT @count = COUNT(*) FROM #TiposDeduccion;
			END

			DROP TABLE #TiposDeduccion
		COMMIT TRANSACTION CargarTipoDeduccion

	END TRY
	BEGIN CATCH
		IF @@Trancount>0 
			ROLLBACK TRANSACTION CargarTipoDeduccion;

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
