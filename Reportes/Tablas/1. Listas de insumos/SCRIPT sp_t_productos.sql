-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_productos') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_productos
    IF OBJECT_ID('dbo.sp_t_productos') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_productos >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_productos >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_productos
(
	@operacion		VARCHAR(5),

	@id				INT 			= NULL,
	@id_unidad		INT				= NULL,
	@id_procedencia	INT				= NULL,
	@id_iva			INT				= NULL,
	@nombre			VARCHAR (30)    = NULL,
	@valor			NUMERIC (18, 2)	= NULL,
	@sn_iva			BIT				= NULL

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
			id_unidad		,
			id_procedencia	,
			id_iva			,
			nombre			,
			valor			,
			sn_iva			
		FROM
			t_productos
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_unidad		,
				id_procedencia	,
				id_iva			,
				nombre			,
				valor			,
				sn_iva			,		

				@operacion
			FROM
				t_productos 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_productos WHERE id = @id 
				)				
					DELETE FROM t_productos 
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
		IF EXISTS (SELECT 1 FROM t_productos WHERE id = @id )		
		BEGIN	
				
			UPDATE t_productos 
				SET id_unidad		= ISNULL (@id_unidad, id_unidad),
					id_procedencia	= ISNULL (@id_procedencia, id_procedencia),
					id_iva			= ISNULL (@id_iva, id_iva),
					nombre			= ISNULL (@nombre, nombre),
					valor			= ISNULL (@valor, valor),
					sn_iva			= ISNULL (@sn_iva, sn_iva)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_productos (
				id_unidad		,
				id_procedencia	,
				id_iva			,
				nombre			,
				valor			,
				sn_iva					
			)
			VALUES(
				@id_unidad		,
				@id_procedencia	,
				@id_iva			,
				@nombre			,
				@valor			,
				@sn_iva			
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_productos') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_productos >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_productos >>>'
GO