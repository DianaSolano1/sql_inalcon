-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_cuadrilla_detalle') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_cuadrilla_detalle
    IF OBJECT_ID('dbo.sp_t_cuadrilla_detalle') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_cuadrilla_detalle >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_cuadrilla_detalle >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_cuadrilla_detalle
(
	@operacion			VARCHAR(5),

	@id					INT				= NULL,
	@id_jornal_empleado	INT				= NULL,
	@id_cuadrilla		INT				= NULL,
	@descripcion		VARCHAR(200)	= NULL,
	@cantidad_oficial	INT				= NULL,
	@cantidad_ayudante	INT				= NULL

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
			id_jornal_empleado	,
			id_cuadrilla		,
			descripcion			,
			cantidad_oficial	,
			cantidad_ayudante
		FROM
			t_cuadrilla_detalle
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_jornal_empleado	,
				id_cuadrilla		,
				descripcion			,
				cantidad_oficial	,
				cantidad_ayudante	,
				
				@operacion
			FROM
				t_cuadrilla_detalle 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_cuadrilla_detalle WHERE id = @id 
				)				
					DELETE FROM t_cuadrilla_detalle 
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
		IF EXISTS (SELECT 1 FROM t_cuadrilla_detalle WHERE id = @id )		
		BEGIN	
				
			UPDATE t_cuadrilla_detalle 
				SET id_jornal_empleado	= ISNULL (@id_jornal_empleado, id_jornal_empleado),
					id_cuadrilla		= ISNULL (@id_cuadrilla, id_cuadrilla),
					descripcion			= ISNULL (@descripcion, descripcion),
					cantidad_oficial	= ISNULL (@cantidad_oficial, cantidad_oficial),
					cantidad_ayudante	= ISNULL (@cantidad_ayudante, cantidad_ayudante)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_cuadrilla_detalle (
				id_jornal_empleado	,
				id_cuadrilla		,
				descripcion			,
				cantidad_oficial	,
				cantidad_ayudante	
			)
			VALUES(
				@id_jornal_empleado	,
				@id_cuadrilla		,
				@descripcion		,
				@cantidad_oficial	,
				@cantidad_ayudante
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_cuadrilla_detalle') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_cuadrilla_detalle >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_cuadrilla_detalle >>>'
GO