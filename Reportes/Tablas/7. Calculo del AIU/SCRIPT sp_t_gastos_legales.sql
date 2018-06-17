---------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_gastos_legales') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_gastos_legales
    IF OBJECT_ID('dbo.sp_t_gastos_legales') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_gastos_legales >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_gastos_legales >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_gastos_legales
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_AIU			INT				= NULL,
	@descripcion	VARCHAR (200)	= NULL,
	@porcentaje		NUMERIC (6, 3)	= NULL,
	@valores		NUMERIC (19,2)	= NULL
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
			id_AIU		,
			descripcion	,
			valores		,
			porcentaje
		FROM
			t_gastos_legales
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 			,
				id_AIU		,
				descripcion	,
				valores		,
				porcentaje	,
				
				@operacion
			FROM
				t_gastos_legales 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_gastos_legales WHERE id = @id 
				)				
					DELETE FROM t_gastos_legales 
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
		IF EXISTS (SELECT 1 FROM t_gastos_legales WHERE id = @id )		
		BEGIN	
				
			UPDATE t_gastos_legales 
				SET id_AIU		= ISNULL (@id_AIU, id_AIU),
					descripcion	= ISNULL (@descripcion, descripcion),
					valores		= ISNULL (@valores, valores),
					porcentaje	= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_gastos_legales (
				id_AIU		,
				descripcion	,
				valores		,
				porcentaje
			)
			VALUES(
				@id_AIU			,
				@descripcion	,
				@valores		,
				@porcentaje
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_gastos_legales') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_gastos_legales >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_gastos_legales >>>'
GO