-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_factor_detalle
IF OBJECT_ID('dbo.sp_t_factor_detalle') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_factor_detalle
    IF OBJECT_ID('dbo.sp_t_factor_detalle') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_factor_detalle >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_factor_detalle >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_factor_detalle
(
	@operacion			VARCHAR(5),

	@id					INT 			= NULL,
	@id_factor_subitem	INT				= NULL,
	@nombre				VARCHAR (200)   = NULL,
	@porcentaje			INT				= NULL

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
			id_factor_subitem	,
			nombre				,
			porcentaje		
		FROM
			t_factor_detalle
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
				id 					,
				id_factor_subitem	,
				nombre				,
				porcentaje			,		

				@operacion
			FROM
				t_factor_detalle 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_factor_detalle 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_factor_detalle WHERE id = @id )		
		BEGIN	
				
			UPDATE t_factor_detalle 
				SET id_factor_subitem	= ISNULL (@id_factor_subitem, id_factor_subitem),
					nombre				= ISNULL (@nombre, nombre),
					porcentaje			= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_factor_detalle (
				id_factor_subitem	,
				nombre				,
				porcentaje					
			)
			VALUES(
				@id_factor_subitem	,
				@nombre				,
				@porcentaje				
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_factor_detalle') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_factor_detalle >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_factor_detalle >>>'
GO