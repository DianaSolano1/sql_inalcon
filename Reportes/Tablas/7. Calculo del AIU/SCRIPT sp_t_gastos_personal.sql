---------------------------------------------------------------------------
-- sp_t_gastos_personal
IF OBJECT_ID('dbo.sp_t_gastos_personal') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_gastos_personal
    IF OBJECT_ID('dbo.sp_t_gastos_personal') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_gastos_personal >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_gastos_personal >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_gastos_personal
(
	@operacion		VARCHAR(5),

	@id						INT				= NULL,
	@id_AIU					INT				= NULL,
	@id_empleado			INT				= NULL,
	@cantidad_empleado		INT				= NULL,
	@factor_prestacional	NUMERIC (5, 2)	= NULL,
	@valor					NUMERIC (20, 2)	= NULL,
	@dedicacion				NUMERIC (6, 3)	= NULL,
	@tiempo_obra			NUMERIC (5, 2)	= NULL
)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'							--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 					,
			id_AIU				,
			id_empleado			,
			cantidad_empleado	,
			factor_prestacional	,
			valor				,
			dedicacion			,
			tiempo_obra
		FROM
			t_gasto_personal
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'C2'							--> Consulta gastos de personal
	BEGIN
	
		SELECT	gp.id,
				cs.nombre AS 'gastos_personal',
				gp.cantidad_empleado AS 'cantidad',
				gp.factor_prestacional,
				gp.valor,
				gp.dedicacion,
				gp.tiempo_obra,
				dbo.GastosPTotal(gp.id) AS 'total',
				dbo.GastosPPorcentaje(gp.id) AS 'porcentaje',
				dbo.GastosPSTI() AS 'GastosPSTI',
				dbo.GastosPTotalPorcentaje() AS 'GastosPTotalPorcentaje'
		FROM t_gasto_personal gp
				LEFT JOIN t_cargo_sueldo cs ON gp.id_empleado = cs.id
				LEFT JOIN t_AIU aiu ON gp.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		ORDER BY gp.id 
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_AIU				,
				id_empleado			,
				cantidad_empleado	,
				factor_prestacional	,
				valor				,
				dedicacion			,
				tiempo_obra			,
				
				@operacion
			FROM
				t_gasto_personal 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_gasto_personal 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_gasto_personal WHERE id = @id )		
		BEGIN	
				
			UPDATE t_gasto_personal 
				SET id_AIU				= ISNULL (@id_AIU, id_AIU),
					id_empleado			= ISNULL (@id_empleado, id_empleado),
					cantidad_empleado	= ISNULL (@cantidad_empleado, cantidad_empleado),
					factor_prestacional	= ISNULL (@factor_prestacional, factor_prestacional),
					valor				= ISNULL (@valor, valor),
					dedicacion			= ISNULL (@dedicacion, dedicacion),
					tiempo_obra			= ISNULL (@tiempo_obra, tiempo_obra)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_gasto_personal (
				id_AIU				,
				id_empleado			,
				cantidad_empleado	,
				factor_prestacional	,
				valor				,
				dedicacion			
			)
			VALUES(
				@id_AIU					,
				@id_empleado			,
				@cantidad_empleado		,
				@factor_prestacional	,
				@valor					,
				@dedicacion
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_gastos_personal') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_gastos_personal >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_gastos_personal >>>'
GO