-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_apu_transporte_material') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu_transporte_material
    IF OBJECT_ID('dbo.sp_t_apu_transporte_material') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu_transporte_material >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu_transporte_material >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu_transporte_material
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_apu			INT				= NULL,
	@id_productos	INT				= NULL,
	@distancia		NUMERIC (10, 2)	= NULL,
	@tarifa			NUMERIC (10, 2)	= NULL

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
			id_apu			,
			id_productos	,
			distancia		,
			tarifa
		FROM
			t_apu_transporte_material
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_apu			,
				id_productos	,
				distancia		,
				tarifa			,
				
				@operacion
			FROM
				t_apu_transporte_material 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_apu_transporte_material WHERE id = @id 
				)				
					DELETE FROM t_apu_transporte_material 
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
		IF EXISTS (SELECT 1 FROM t_apu_transporte_material WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu_transporte_material 
				SET id_apu			= ISNULL (@id_apu, id_apu),
					id_productos	= ISNULL (@id_productos, id_productos),
					distancia		= ISNULL (@distancia, distancia),
					tarifa			= ISNULL (@tarifa, tarifa)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu_transporte_material (
				id_apu			,
				id_productos	,
				distancia		,
				tarifa	
			)
			VALUES(
				@id_apu			,
				@id_productos	,
				@distancia		,
				@tarifa
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu_transporte_material') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu_transporte_material >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu_transporte_material >>>'
GO