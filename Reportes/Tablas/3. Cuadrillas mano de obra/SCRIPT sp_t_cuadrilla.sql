-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_cuadrilla
IF OBJECT_ID('dbo.sp_t_cuadrilla') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_cuadrilla
    IF OBJECT_ID('dbo.sp_t_cuadrilla') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_cuadrilla >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_cuadrilla >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_cuadrilla
(
	@operacion			VARCHAR(5),

	@id					INT = NULL,
	@id_salario_minimo	INT	= NULL,
	@dias_labor			INT = NULL,
	@horas_dia			INT = NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'						--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 					,
			id_salario_minimo	,
			dias_labor			,
			horas_dia
		FROM
			t_cuadrilla
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END

	END ELSE	

	IF @operacion = 'C2'					--> Reporte de una sola linea para la cuadrilla
	BEGIN
		SELECT	l.valor AS 'salario_minimo',
				c.dias_labor AS 'dias_laborales',
				c.horas_dia,
				dbo.calcularFactorMultiplicadorTotal() as 'factor_prestacional'
		FROM t_cuadrilla c
		LEFT JOIN t_legal l ON c.id_salario_minimo = l.id
	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_salario_minimo	,
				dias_labor			,
				horas_dia			,
				
				@operacion
			FROM
				t_cuadrilla 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_cuadrilla 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_cuadrilla WHERE id = @id )		
		BEGIN	
				
			UPDATE t_cuadrilla 
				SET id_salario_minimo	= ISNULL (@id_salario_minimo, id_salario_minimo),
					dias_labor			= ISNULL (@dias_labor, dias_labor),
					horas_dia			= ISNULL (@horas_dia, horas_dia)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_cuadrilla (
				id_salario_minimo	,
				dias_labor			,
				horas_dia
			)
			VALUES(
				@id_salario_minimo	,
				@dias_labor			,
				@horas_dia
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_cuadrilla') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_cuadrilla >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_cuadrilla >>>'
GO