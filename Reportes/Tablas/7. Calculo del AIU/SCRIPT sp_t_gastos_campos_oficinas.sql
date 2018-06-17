---------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_gastos_campos_oficinas') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_gastos_campos_oficinas
    IF OBJECT_ID('dbo.sp_t_gastos_campos_oficinas') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_gastos_campos_oficinas >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_gastos_campos_oficinas >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_gastos_campos_oficinas
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_AIU			INT				= NULL,
	@descripcion	VARCHAR (200)	= NULL,
	@valor			NUMERIC (19,3)	= NULL,
	@dedicacion		NUMERIC (6, 3)	= NULL,
	@tiempo_obra	NUMERIC (5, 2)	= NULL
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
			valor		,
			dedicacion	,
			tiempo_obra	
		FROM
			t_gastos_campos_oficinas
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 			,
				id_AIU		,
				descripcion	,
				valor		,
				dedicacion	,
				tiempo_obra	,
				
				@operacion
			FROM
				t_gastos_campos_oficinas 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_gastos_campos_oficinas WHERE id = @id 
				)				
					DELETE FROM t_gastos_campos_oficinas 
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
		IF EXISTS (SELECT 1 FROM t_gastos_campos_oficinas WHERE id = @id )		
		BEGIN	
				
			UPDATE t_gastos_campos_oficinas 
				SET id_AIU		= ISNULL (@id_AIU, id_AIU),
					descripcion	= ISNULL (@descripcion, descripcion),
					valor		= ISNULL (@valor, valor),
					dedicacion	= ISNULL (@dedicacion, dedicacion),
					tiempo_obra	= ISNULL (@tiempo_obra, tiempo_obra)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_gastos_campos_oficinas (
				id_AIU		,
				descripcion	,
				valor		,
				dedicacion	,
				tiempo_obra
			)
			VALUES(
				@id_AIU			,
				@descripcion	,
				@valor			,
				@dedicacion		,
				@tiempo_obra
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_gastos_campos_oficinas') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_gastos_campos_oficinas >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_gastos_campos_oficinas >>>'
GO