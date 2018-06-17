---------------------------------------------------------------------------
-- sp_t_perfil
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
	
	IF @operacion = 'C1'
	BEGIN
	
		SELECT 
			id 				,
			id_experiencia	,
			id_cargo		,
			cantidad		,
			dedicacion		,
			tiempo_ejecucion
		FROM
			t_costos_personal
	
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
				t_costos_personal 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_costos_personal WHERE id = @id 
				)				
					DELETE FROM t_costos_personal 
					WHERE 
						id = @ID
				ELSE
					BEGIN
						ROLLBACK TRAN
						
						RETURN;
					END
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_costos_personal WHERE id = @id )		
		BEGIN	
				
			UPDATE t_costos_personal 
				SET id_experiencia		= ISNULL (@id_experiencia, id_experiencia),
					id_cargo			= ISNULL (@id_cargo, id_cargo),
					cantidad			= ISNULL (@cantidad, cantidad),
					dedicacion			= ISNULL (@dedicacion, dedicacion),
					tiempo_ejecucion	= ISNULL (@tiempo_ejecucion, tiempo_ejecucion)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_costos_personal (
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