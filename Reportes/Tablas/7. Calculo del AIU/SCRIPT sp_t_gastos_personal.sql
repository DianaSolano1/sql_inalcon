---------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_gastos_personal') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_gastos_personal
    IF OBJECT_ID('dbo.sp_t_gastos_personal') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_gastos_personal >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_gastos_personal >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_gastos_personal
(
	@operacion		VARCHAR(5),

	@id						INT				= NULL,
	@id_AIU					INT				= NULL,
	@id_empleado			INT				= NULL,
	@cantidad_empleado		INT				= NULL,
	@factor_prestacional	NUMERIC (5, 2)	= NULL,
	@valor					NUMERIC (20, 2)	= NULL,
	@dedicacion				NUMERIC (6, 3)	= NULL,
	@tiempo_obra			NUMERIC (5, 2)	= NULL
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
			id_AIU				,
			id_empleado			,
			cantidad_empleado	,
			factor_prestacional	,
			valor				,
			dedicacion			,
			tiempo_obra
		FROM
			t_gastos_personal
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_AIU				,
				id_empleado			,
				cantidad_empleado	,
				factor_prestacional	,
				valor				,
				dedicacion			,
				tiempo_obra			,
				
				@operacion
			FROM
				t_gastos_personal 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_gastos_personal WHERE id = @id 
				)				
					DELETE FROM t_gastos_personal 
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
		IF EXISTS (SELECT 1 FROM t_gastos_personal WHERE id = @id )		
		BEGIN	
				
			UPDATE t_gastos_personal 
				SET id_AIU				= ISNULL (@id_AIU, id_AIU),
					id_empleado			= ISNULL (@id_empleado, id_empleado),
					cantidad_empleado	= ISNULL (@cantidad_empleado, cantidad_empleado),
					factor_prestacional	= ISNULL (@factor_prestacional, factor_prestacional),
					valor				= ISNULL (@valor, valor),
					dedicacion			= ISNULL (@dedicacion, dedicacion),
					tiempo_obra			= ISNULL (@tiempo_obra, tiempo_obra)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_gastos_personal (
				id_AIU				,
				id_empleado			,
				cantidad_empleado	,
				factor_prestacional	,
				valor				,
				dedicacion			
			)
			VALUES(
				@id_AIU					,
				@id_empleado			,
				@cantidad_empleado		,
				@factor_prestacional	,
				@valor					,
				@dedicacion
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_gastos_personal') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_gastos_personal >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_gastos_personal >>>'
GO