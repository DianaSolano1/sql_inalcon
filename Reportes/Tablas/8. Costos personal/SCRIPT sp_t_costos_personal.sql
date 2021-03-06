---------------------------------------------------------------------------
-- sp_t_costos_personal
IF OBJECT_ID('dbo.sp_t_costos_personal') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_costos_personal
    IF OBJECT_ID('dbo.sp_t_costos_personal') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_costos_personal >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_costos_personal >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_costos_personal
(
	@operacion			VARCHAR(5),

	@id					INT				= NULL,
	@id_experiencia		INT				= NULL,
	@id_cargo			INT				= NULL,
	@cantidad			INT				= NULL,
	@dedicacion			NUMERIC (6, 3)	= NULL,
	@tiempo_ejecucion	INT				= NULL
)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'							--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 				,
			id_experiencia	,
			id_cargo		,
			cantidad		,
			dedicacion		,
			tiempo_ejecucion
		FROM
			t_costo_personal
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'C2'							--> Consulta costos personal
	BEGIN
	
		SELECT	
			rc.nombre AS 'rol',
			cs.nombre AS 'cargo',
			cp.cantidad,
			ex.nombre AS 'experiencia_general_específica',
			cp.dedicacion,
			cp.tiempo_ejecucion,
			cs.sueldo_basico,
			dbo.CostoPersonalParcial(cs.ID) AS 'costo_parcial'
		FROM 
			t_costo_personal cp
			LEFT JOIN t_experiencia ex ON cp.id_experiencia = ex.ID
			LEFT JOIN t_cargo_sueldo cs ON cp.id_experiencia = cs.ID
			LEFT JOIN t_rol_cargo rc ON cs.id_rol = rc.ID
		ORDER BY rc.nombre 
	
	END ELSE

	IF @operacion = 'C3'							--> Consulta el resultado final de los costos personal
	BEGIN

		DECLARE @T_TOTAL_COSTOS_PERSONAL TABLE 
		(
			sub_total		NUMERIC (18, 2)	NOT NULL,
			FM				NUMERIC (5, 2)	NOT NULL,
			total_personal	NUMERIC (18, 2)	NULL
		)

		INSERT @T_TOTAL_COSTOS_PERSONAL (
				sub_total,
				FM
			)
		SELECT	(dbo.CostoPersonalSubTotal()),
				2

		UPDATE @T_TOTAL_COSTOS_PERSONAL
		SET
			total_personal			= (dbo.TotalPersonal())
		FROM
			@T_TOTAL_COSTOS_PERSONAL ADM
		WHERE
			total_personal	IS NULL

		SELECT * FROM @T_TOTAL_COSTOS_PERSONAL

	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_experiencia		,
				id_cargo			,
				cantidad			,
				dedicacion			,
				tiempo_ejecucion	,
				
				@operacion
			FROM
				t_costo_personal 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_costo_personal 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_costo_personal WHERE id = @id )		
		BEGIN	
				
			UPDATE t_costo_personal 
				SET id_experiencia		= ISNULL (@id_experiencia, id_experiencia),
					id_cargo			= ISNULL (@id_cargo, id_cargo),
					cantidad			= ISNULL (@cantidad, cantidad),
					dedicacion			= ISNULL (@dedicacion, dedicacion),
					tiempo_ejecucion	= ISNULL (@tiempo_ejecucion, tiempo_ejecucion)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_costo_personal (
				id 					,
				id_experiencia		,
				id_cargo			,
				cantidad			,
				dedicacion			,
				tiempo_ejecucion
			)
			VALUES(
				@id 				,
				@id_experiencia		,
				@id_cargo			,
				@cantidad			,
				@dedicacion			,
				@tiempo_ejecucion
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_costos_personal') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_costos_personal >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_costos_personal >>>'
GO