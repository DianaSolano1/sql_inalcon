---------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_costos_directos') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_costos_directos
    IF OBJECT_ID('dbo.sp_t_costos_directos') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_costos_directos >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_costos_directos >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_costos_directos
(
	@operacion	VARCHAR(5),

	@id					INT				= NULL,
	@id_unidad			INT				= NULL,
	@nombre				VARCHAR (200)	= NULL,
	@cantidad			INT				= NULL,
	@dedicacion			NUMERIC (6, 3)	= NULL,
	@tiempo_ejecucion	INT				= NULL,
	@tarifa				NUMERIC (18,2)	= NULL
)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'
	BEGIN
	
		SELECT 
			id 					,
			id_unidad			,
			nombre				,
			cantidad			,
			dedicacion			,
			tiempo_ejecucion	,
			tarifa
		FROM
			t_costos_directos
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_unidad			,
				nombre				,
				cantidad			,
				dedicacion			,
				tiempo_ejecucion	,
				tarifa				,
				
				@operacion
			FROM
				t_costos_directos 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_costos_directos WHERE id = @id 
				)				
					DELETE FROM t_costos_directos 
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
		IF EXISTS (SELECT 1 FROM t_costos_directos WHERE id = @id )		
		BEGIN	
				
			UPDATE t_costos_directos 
				SET id_unidad			= ISNULL (@id_unidad, id_unidad),
					nombre				= ISNULL (@nombre, nombre),
					cantidad			= ISNULL (@cantidad, cantidad),
					dedicacion			= ISNULL (@dedicacion, dedicacion),
					tiempo_ejecucion	= ISNULL (@tiempo_ejecucion, tiempo_ejecucion),
					tarifa				= ISNULL (@tarifa, tarifa)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_costos_directos (
				id 					,
				id_unidad			,
				nombre				,
				cantidad			,
				dedicacion			,
				tiempo_ejecucion	,
				tarifa	
			)
			VALUES(
				@id_unidad			,
				@nombre				,
				@cantidad			,
				@dedicacion			,
				@tiempo_ejecucion	,
				@tarifa
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_costos_directos') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_costos_directos >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_costos_directos >>>'
GO