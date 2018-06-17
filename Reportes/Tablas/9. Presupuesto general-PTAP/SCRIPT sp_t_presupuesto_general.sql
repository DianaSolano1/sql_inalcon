---------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_presupuesto_general') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_presupuesto_general
    IF OBJECT_ID('dbo.sp_t_presupuesto_general') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_presupuesto_general >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_presupuesto_general >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_presupuesto_general
(
	@operacion		VARCHAR(5),

	@id				INT			= NULL,
	@id_APU			INT			= NULL,
	@item			INT			= NULL,
	@descripcion	VARCHAR(50)	= NULL,
	@cantidad		INT			= NULL
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
			id_APU			,	
			item			,
			descripcion		,
			cantidad
		FROM
			t_presupuesto_general
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_APU			,
				item			,
				descripcion		,
				cantidad		,
				
				@operacion
			FROM
				t_presupuesto_general 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_presupuesto_general WHERE id = @id 
				)				
					DELETE FROM t_presupuesto_general 
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
		IF EXISTS (SELECT 1 FROM t_presupuesto_general WHERE id = @id )		
		BEGIN	
				
			UPDATE t_presupuesto_general 
				SET id_APU			= ISNULL (@id_APU, id_APU),
					item			= ISNULL (@item, item),
					descripcion		= ISNULL (@descripcion, descripcion),
					cantidad		= ISNULL (@cantidad, cantidad)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_presupuesto_general (
				id 				,
				id_APU			,
				item			,
				descripcion		,
				cantidad		
			)
			VALUES(
				@id 			,
				@id_APU			,
				@item			,
				@descripcion	,
				@cantidad		
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_presupuesto_general') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_presupuesto_general >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_presupuesto_general >>>'
GO