-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_legal') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_legal
    IF OBJECT_ID('dbo.sp_t_legal') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_legal >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_legal >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_legal
(
	@operacion		VARCHAR(5),

	@id		INT 			= NULL,
	@nombre	VARCHAR (30)    = NULL,
	@anno	DATE 			= NULL,
	@valor	NUMERIC (18, 2)	= NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'
	BEGIN
	
		SELECT 
			id 		,
			nombre	,
			anno	,
			valor
		FROM
			t_legal
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 		,
				nombre	,
				anno	,
				valor	,

				@operacion
			FROM
				t_legal 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_legal WHERE id = @id 
				)				
					DELETE FROM t_legal 
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
		IF EXISTS (SELECT 1 FROM t_legal WHERE id = @id )		
		BEGIN	
				
			UPDATE t_legal 
				SET nombre	= ISNULL (@nombre, nombre),
					anno	= ISNULL (@anno, anno),
					valor	= ISNULL (@valor, valor)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_legal (
				nombre	,
				anno	,
				valor		
			)
			VALUES(
				@nombre ,
				@anno	,
				@valor	
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_legal') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_legal >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_legal >>>'
GO