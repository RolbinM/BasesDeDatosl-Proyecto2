USE [BDPlanillaObrera]
GO

/****** Object:  StoredProcedure [dbo].[sp_CargarXML]    Script Date: 25/05/2021 6:39:14 ******/
SET ANSI_NULLS ON
GO

SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [dbo].[sp_CargarXML]
AS
BEGIN
	SET NOCOUNT ON

	BEGIN TRY
		DECLARE @OutResultCode INT
		SET @OutResultCode = 0;

		BEGIN TRANSACTION Cargar

			-- Cargar Datos
			EXEC sp_CargarPuesto
			EXEC sp_CargarDepartamento
			EXEC sp_CargarTipoDocumentoIdentidad
			EXEC sp_CargarTipoJornada
			EXEC sp_CargarTipoMovimiento
			EXEC sp_CargarFeriado
			EXEC sp_CargarTipoDeduccion
			EXEC sp_CargarUsuario

			-- Cargar Operaciones
			EXEC sp_CargarOperaciones
			EXEC sp_CargarInsercionEmpleados
			EXEC sp_CargarEliminarEmpleados
			EXEC sp_CargarInsercionJornada
			EXEC sp_CargarInsercionMarcaAsistencia
			EXEC sp_CargarAsociaDeduccion
			EXEC sp_CargarDesasociaDeduccion


			-- CargarEmpleados
			DECLARE @countOperaciones INT
			SELECT @countOperaciones = COUNT(*) FROM ##Operaciones

			while @countOperaciones > 0
			BEGIN
				DECLARE @FechaOperacion DATE = (SELECT TOP(1) FechaOperacion FROM ##Operaciones);
				DECLARE @DiaActual INT = DATEPART(WEEKDAY, @FechaOperacion)
				DECLARE @MesActual INT = DATEPART(MONTH, @FechaOperacion)

				-- Donde ingresan las acciones 
				EXEC sp_IngresarMarcaAsistencia @FechaOperacion
				EXEC sp_EliminarEmpleado @FechaOperacion
				EXEC sp_IngresarEmpleados @FechaOperacion							-- Funcionando con el trigger y todo
				--EXEC sp_IngresarDeduccion @FechaOperacion
				--EXEC sp_EliminarDeduccion @FechaOperacion

				IF @DiaActual = 4																			-- Saca Dias de la semana
				BEGIN
					DECLARE @SiguienteJueves DATE = DATEADD(DAY, 7, @FechaOperacion)

					IF NOT EXISTS(SELECT 1 FROM dbo.MesPlanilla)
					BEGIN 
						INSERT INTO dbo.MesPlanilla(FechaInicio)
						VALUES(DATEADD(DAY, 1, @FechaOperacion));

						DECLARE @IdMesActual INT = IDENT_CURRENT('MesPlanilla') 

						INSERT INTO SemanaPlanilla
						VALUES(
							DATEADD(DAY, 1, @FechaOperacion),
							@SiguienteJueves,
							@IdMesActual
						);
					END
	
					ELSE
					BEGIN  
						DECLARE @IdMes INT = IDENT_CURRENT('MesPlanilla')
						DECLARE @MesPlanilla DATE = (SELECT FechaInicio FROM dbo.MesPlanilla WHERE Id = @IdMes);
						DECLARE @UltimoMesPlanilla INT = DATEPART(MONTH, @MesPlanilla)

						IF @MesActual > @UltimoMesPlanilla
						BEGIN
							UPDATE dbo.MesPlanilla
							SET FechaFin = @FechaOperacion
							WHERE Id = @IdMes 

							INSERT INTO dbo.MesPlanilla(FechaInicio)
							VALUES(DATEADD(DAY, 1, @FechaOperacion));

							DECLARE @NuevoIdMes INT = IDENT_CURRENT('MesPlanilla')

							INSERT INTO SemanaPlanilla
							VALUES(
								DATEADD(DAY, 1, @FechaOperacion),
								@SiguienteJueves,
								@NuevoIdMes
							);
						END
						ELSE
						BEGIN
							INSERT INTO SemanaPlanilla
							VALUES(
								DATEADD(DAY, 1, @FechaOperacion),
								@SiguienteJueves,
								@IdMes
							);
						END
					END

					EXEC sp_IngresarJornada @FechaOperacion
				END

				DELETE TOP (1) FROM ##Operaciones
				SELECT @countOperaciones = COUNT(*) FROM ##Operaciones;

			END

		COMMIT TRANSACTION Cargar

	END TRY
	BEGIN CATCH
		IF @@Trancount>0 
			ROLLBACK TRANSACTION Cargar;

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


