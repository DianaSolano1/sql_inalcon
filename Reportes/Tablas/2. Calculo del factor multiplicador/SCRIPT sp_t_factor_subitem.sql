-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_factor_subitem
IF OBJECT_ID('dbo.sp_t_factor_subitem') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_factor_subitem
    IF OBJECT_ID('dbo.sp_t_factor_subitem') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_factor_subitem >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_factor_subitem >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_factor_subitem
(
	@operacion		VARCHAR(5),

	@id				INT 			= NULL,
	@id_factor_base	INT				= NULL,
	@item			VARCHAR (5)		= NULL,
	@nombre			VARCHAR (200)   = NULL,
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
			id 				,
			id_factor_base	,
			item			,
			nombre			,
			porcentaje		
		FROM
			t_factor_subitem
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
				id_factor_base	,
				item			,
				nombre			,
				porcentaje		,		

				@operacion
			FROM
				t_factor_subitem 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_factor_subitem 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_factor_subitem WHERE id = @id )		
		BEGIN	
				
			UPDATE t_factor_subitem 
				SET id_factor_base	= ISNULL (@id_factor_base, id_factor_base),
					item			= ISNULL (@item, item),
					nombre			= ISNULL (@nombre, nombre),
					porcentaje		= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_factor_subitem (
				id_factor_base	,
				item			,
				nombre			,
				porcentaje					
			)
			VALUES(
				@id_factor_base	,
				@item			,
				@nombre			,
				@porcentaje				
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_factor_subitem') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_factor_subitem >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_factor_subitem >>>'
GO