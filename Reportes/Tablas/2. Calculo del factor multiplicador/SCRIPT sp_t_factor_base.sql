-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_factor_base') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_factor_base
    IF OBJECT_ID('dbo.sp_t_factor_base') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_factor_base >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_factor_base >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_factor_base
(
	@operacion		VARCHAR(5),

	@id				INT 			= NULL,
	@item			VARCHAR (5)		= NULL,
	@nombre			VARCHAR (200)    = NULL,
	@porcentaje		INT				= NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'
	BEGIN
	
		SELECT 
			id 			,
			item		,
			nombre		,
			porcentaje		
		FROM
			t_factor_base
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 			,
				item		,
				nombre		,
				porcentaje	,		

				@operacion
			FROM
				t_factor_base 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_factor_base WHERE id = @id 
				)				
					DELETE FROM t_factor_base 
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
		IF EXISTS (SELECT 1 FROM t_factor_base WHERE id = @id )		
		BEGIN	
				
			UPDATE t_factor_base 
				SET item		= ISNULL (@item, item),
					nombre		= ISNULL (@nombre, nombre),
					porcentaje	= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_factor_base (
				item		,
				nombre		,
				porcentaje					
			)
			VALUES(
				@item		,
				@nombre		,
				@porcentaje				
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_factor_base') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_factor_base >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_factor_base >>>'
GO