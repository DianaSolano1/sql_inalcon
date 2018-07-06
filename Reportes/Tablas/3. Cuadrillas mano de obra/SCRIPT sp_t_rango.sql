-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_rango
IF OBJECT_ID('dbo.sp_t_rango') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_rango
    IF OBJECT_ID('dbo.sp_t_rango') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_rango >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_rango >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_rango
(
	@operacion		VARCHAR(5),

	@id				INT 			= NULL,
	@nombre			VARCHAR (200)   = NULL

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
			nombre	
		FROM
			t_rango
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END

	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				nombre			,
				
				@operacion
			FROM
				t_rango 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_rango WHERE id = @id 
				)				
					DELETE FROM t_rango 
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
		IF EXISTS (SELECT 1 FROM t_rango WHERE id = @id )		
		BEGIN	
				
			UPDATE t_rango 
				SET nombre			= ISNULL (@nombre, nombre)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_rango (
				nombre					
			)
			VALUES(
				@nombre				
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_rango') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_rango >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_rango >>>'
GO