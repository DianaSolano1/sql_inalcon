---------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_apu_mano_obra') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu_mano_obra
    IF OBJECT_ID('dbo.sp_t_apu_mano_obra') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu_mano_obra >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu_mano_obra >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu_mano_obra
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_apu			INT				= NULL,
	@id_cuadrilla	INT				= NULL,
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
			id_cuadrilla	,
			rendimiento
		FROM
			t_apu_mano_obra
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_apu			,
				id_cuadrilla	,
				rendimiento		,
				
				@operacion
			FROM
				t_apu_mano_obra 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_apu_mano_obra WHERE id = @id 
				)				
					DELETE FROM t_apu_mano_obra 
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
		IF EXISTS (SELECT 1 FROM t_apu_mano_obra WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu_mano_obra 
				SET id_apu			= ISNULL (@id_apu, id_apu),
					id_cuadrilla	= ISNULL (@id_cuadrilla, id_cuadrilla),
					rendimiento		= ISNULL (@rendimiento, rendimiento)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu_mano_obra (
				id_apu			,
				id_cuadrilla	,
				rendimiento
			)
			VALUES(
				@id_apu			,
				@id_cuadrilla	,
				@rendimiento
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu_mano_obra') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu_mano_obra >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu_mano_obra >>>'
GO