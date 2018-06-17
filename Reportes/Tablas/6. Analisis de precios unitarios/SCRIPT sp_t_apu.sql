-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_apu') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu
    IF OBJECT_ID('dbo.sp_t_apu') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu
(
	@operacion			VARCHAR(5),

	@id					INT				= NULL,
	@codigo				VARCHAR(5)		= NULL,
	@nombre				VARCHAR(50)		= NULL,
	@id_unidad			INT				= NULL,
	@factor_hm			NUMERIC (6, 3)	= NULL,
	@factor_desperdicio	NUMERIC (6, 3)	= NULL,
	@sn_activa			BIT				= NULL

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
			codigo				,
			nombre				,
			id_unidad			,
			factor_hm			,
			factor_desperdicio	,
			sn_activa
		FROM
			t_apu
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				codigo				,
				nombre				,
				id_unidad			,
				factor_hm			,
				factor_desperdicio	,
				sn_activa			,
				
				@operacion
			FROM
				t_apu 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_apu WHERE id = @id 
				)				
					DELETE FROM t_apu 
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
		IF EXISTS (SELECT 1 FROM t_apu WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu 
				SET codigo				= ISNULL (@codigo, codigo),
					nombre				= ISNULL (@nombre, nombre),
					id_unidad			= ISNULL (@id_unidad, nombre),
					factor_hm			= ISNULL (@factor_hm, factor_hm),
					factor_desperdicio	= ISNULL (@factor_desperdicio, factor_desperdicio),
					sn_activa			= ISNULL (@sn_activa, sn_activa)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu (
				codigo				,
				nombre				,
				id_unidad			,
				factor_hm			,
				factor_desperdicio	,
				sn_activa	
			)
			VALUES(
				@codigo				,
				@nombre				,
				@id_unidad			,
				@factor_hm			,
				@factor_desperdicio	,
				@sn_activa
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu >>>'
GO