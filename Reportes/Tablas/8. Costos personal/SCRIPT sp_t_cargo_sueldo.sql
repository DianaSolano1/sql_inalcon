---------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_cargo_sueldo') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_cargo_sueldo
    IF OBJECT_ID('dbo.sp_t_cargo_sueldo') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_cargo_sueldo >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_cargo_sueldo >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_cargo_sueldo
(
	@operacion	VARCHAR(5),

	@id				INT				= NULL,
	@id_rol			INT				= NULL,
	@nombre			VARCHAR (200)	= NULL,
	@sueldo_basico	NUMERIC (18,2)	= NULL
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
			id_rol			,
			nombre			,
			sueldo_basico
		FROM
			t_cargo_sueldo
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_rol			,
				nombre			,
				sueldo_basico	,
				
				@operacion
			FROM
				t_cargo_sueldo 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_cargo_sueldo WHERE id = @id 
				)				
					DELETE FROM t_cargo_sueldo 
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
		IF EXISTS (SELECT 1 FROM t_cargo_sueldo WHERE id = @id )		
		BEGIN	
				
			UPDATE t_cargo_sueldo 
				SET id_rol			= ISNULL (@id_rol, id_rol),
					nombre			= ISNULL (@nombre, nombre),
					sueldo_basico	= ISNULL (@sueldo_basico, sueldo_basico)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_cargo_sueldo (
				id_rol			,
				nombre			,
				sueldo_basico	
			)
			VALUES(
				@id_rol			,
				@nombre			,
				@sueldo_basico
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_cargo_sueldo') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_cargo_sueldo >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_cargo_sueldo >>>'
GO