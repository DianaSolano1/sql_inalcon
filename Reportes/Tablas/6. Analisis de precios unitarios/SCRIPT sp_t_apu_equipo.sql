-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_apu_equipo') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu_equipo
    IF OBJECT_ID('dbo.sp_t_apu_equipo') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu_equipo >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu_equipo >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu_equipo
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_apu			INT				= NULL,
	@id_productos	INT				= NULL,
	@cantidad		NUMERIC (5, 2)	= NULL,
	@rendimiento	NUMERIC (5, 2)	= NULL

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
			id_apu			,
			id_productos	,
			cantidad		,
			rendimiento
		FROM
			t_apu_equipo
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_apu			,
				id_productos	,
				cantidad		,
				rendimiento		,
				
				@operacion
			FROM
				t_apu_equipo 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_apu_equipo WHERE id = @id 
				)				
					DELETE FROM t_apu_equipo 
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
		IF EXISTS (SELECT 1 FROM t_apu_equipo WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu_equipo 
				SET id_apu			= ISNULL (@id_apu, id_apu),
					id_productos	= ISNULL (@id_productos, id_productos),
					cantidad		= ISNULL (@cantidad, cantidad),
					rendimiento		= ISNULL (@rendimiento, rendimiento)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu_equipo (
				id_apu			,
				id_productos	,
				cantidad		,
				rendimiento
			)
			VALUES(
				@id_apu			,
				@id_productos	,
				@cantidad		,
				@rendimiento
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu_equipo') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu_equipo >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu_equipo >>>'
GO