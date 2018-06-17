---------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_detalle_subpresupuesto') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_detalle_subpresupuesto
    IF OBJECT_ID('dbo.sp_t_detalle_subpresupuesto') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_detalle_subpresupuesto >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_detalle_subpresupuesto >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_detalle_subpresupuesto
(
	@operacion		VARCHAR(5),

	@id					INT	= NULL,
	@id_APU				INT	= NULL,
	@id_presupuesto		INT	= NULL,
	@id_subpresupuesto	INT = NULL,
	@item				INT	= NULL,
	@cantidad			INT	= NULL
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
			id_APU				,
			id_presupuesto		,
			id_subpresupuesto	,
			item				,
			cantidad
		FROM
			t_detalle_subpresupuesto
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_APU				,
				id_presupuesto		,
				id_subpresupuesto	,
				item				,
				cantidad			,
				
				@operacion
			FROM
				t_detalle_subpresupuesto 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_detalle_subpresupuesto WHERE id = @id 
				)				
					DELETE FROM t_detalle_subpresupuesto 
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
		IF EXISTS (SELECT 1 FROM t_detalle_subpresupuesto WHERE id = @id )		
		BEGIN	
				
			UPDATE t_detalle_subpresupuesto 
				SET id_APU				= ISNULL (@id_APU, id_APU),
					id_presupuesto		= ISNULL (@id_presupuesto, id_presupuesto),
					id_subpresupuesto	= ISNULL (@id_subpresupuesto, id_subpresupuesto),
					item				= ISNULL (@item, item),
					cantidad			= ISNULL (@cantidad, cantidad)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_detalle_subpresupuesto (
				id 					,
				id_APU				,
				id_presupuesto		,
				id_subpresupuesto	,
				item				,
				cantidad		
			)
			VALUES(
				@id 				,
				@id_APU				,
				@id_presupuesto		,
				@id_subpresupuesto	,
				@item				,
				@cantidad		
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_detalle_subpresupuesto') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_detalle_subpresupuesto >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_detalle_subpresupuesto >>>'
GO