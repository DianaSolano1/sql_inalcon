---------------------------------------------------------------------------
-- sp_t_rol_cargo
IF OBJECT_ID('dbo.sp_t_rol_cargo') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_rol_cargo
    IF OBJECT_ID('dbo.sp_t_rol_cargo') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_rol_cargo >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_rol_cargo >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_rol_cargo
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@nombre			VARCHAR (200)	= NULL
)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'							--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 			,
			nombre	
		FROM
			t_rol_cargo
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
				id 		,
				nombre	,
				
				@operacion
			FROM
				t_rol_cargo 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_rol_cargo 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_rol_cargo WHERE id = @id )		
		BEGIN	
				
			UPDATE t_rol_cargo 
				SET nombre		= ISNULL (@nombre, nombre)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_rol_cargo (
				nombre
			)
			VALUES(
				@nombre
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_rol_cargo') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_rol_cargo >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_rol_cargo >>>'
GO