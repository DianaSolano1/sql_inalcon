-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_apu_materiales') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu_materiales
    IF OBJECT_ID('dbo.sp_t_apu_materiales') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu_materiales >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu_materiales >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu_materiales
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_apu			INT				= NULL,
	@id_productos	INT				= NULL,
	@cantidad		NUMERIC (5, 2)	= NULL

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
			cantidad
		FROM
			t_apu_materiales
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_apu			,
				id_productos	,
				cantidad		,
				
				@operacion
			FROM
				t_apu_materiales 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_apu_materiales WHERE id = @id 
				)				
					DELETE FROM t_apu_materiales 
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
		IF EXISTS (SELECT 1 FROM t_apu_materiales WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu_materiales 
				SET id_apu			= ISNULL (@id_apu, id_apu),
					id_productos	= ISNULL (@id_productos, id_productos),
					cantidad		= ISNULL (@cantidad, cantidad)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu_materiales (
				id_apu			,
				id_productos	,
				cantidad
			)
			VALUES(
				@id_apu			,
				@id_productos	,
				@cantidad
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu_materiales') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu_materiales >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu_materiales >>>'
GO