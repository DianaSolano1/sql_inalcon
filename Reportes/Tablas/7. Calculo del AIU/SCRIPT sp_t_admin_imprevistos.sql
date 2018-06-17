---------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_admin_imprevistos') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_admin_imprevistos
    IF OBJECT_ID('dbo.sp_t_admin_imprevistos') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_admin_imprevistos >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_admin_imprevistos >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_admin_imprevistos
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_AIU			INT				= NULL,
	@descripcion	VARCHAR (200)	= NULL,
	@porcentaje		NUMERIC (6, 3)	= NULL,
	@sn_administra	NUMERIC (19,2)	= NULL
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
			id_AIU			,
			descripcion		,
			sn_administra	,
			porcentaje
		FROM
			t_admin_imprevistos
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_AIU			,
				descripcion		,
				sn_administra	,
				porcentaje		,
				
				@operacion
			FROM
				t_admin_imprevistos 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_admin_imprevistos WHERE id = @id 
				)				
					DELETE FROM t_admin_imprevistos 
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
		IF EXISTS (SELECT 1 FROM t_admin_imprevistos WHERE id = @id )		
		BEGIN	
				
			UPDATE t_admin_imprevistos 
				SET id_AIU			= ISNULL (@id_AIU, id_AIU),
					descripcion		= ISNULL (@descripcion, descripcion),
					sn_administra	= ISNULL (@sn_administra, sn_administra),
					porcentaje		= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_admin_imprevistos (
				id_AIU			,
				descripcion		,
				sn_administra	,
				porcentaje
			)
			VALUES(
				@id_AIU			,
				@descripcion	,
				@sn_administra	,
				@porcentaje
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_admin_imprevistos') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_admin_imprevistos >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_admin_imprevistos >>>'
GO