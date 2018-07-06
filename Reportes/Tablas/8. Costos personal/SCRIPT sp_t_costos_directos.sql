---------------------------------------------------------------------------
-- sp_t_costo_directo
IF OBJECT_ID('dbo.sp_t_costo_directo') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_costo_directo
    IF OBJECT_ID('dbo.sp_t_costo_directo') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_costo_directo >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_costo_directo >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_costo_directo
(
	@operacion	VARCHAR(5),

	@id					INT				= NULL,
	@id_unidad			INT				= NULL,
	@nombre				VARCHAR (200)	= NULL,
	@cantidad			INT				= NULL,
	@dedicacion			NUMERIC (6, 3)	= NULL,
	@tiempo_ejecucion	INT				= NULL,
	@tarifa				NUMERIC (18,2)	= NULL
)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'							--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 					,
			id_unidad			,
			nombre				,
			cantidad			,
			dedicacion			,
			tiempo_ejecucion	,
			tarifa
		FROM
			t_costo_directo
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE
	
	IF @operacion = 'C2'							--> Consulta de otros costos directos
	BEGIN
	
		SELECT	cd.nombre AS 'descripcion',
				cd.cantidad,
				u.nombre AS 'unidad',
				cd.dedicacion,
				cd.tiempo_ejecucion,
				cd.tarifa,
				dbo.CostoDirectoParcial(cd.id) AS 'costo_parcial',
				dbo.CostoDirectoParcialTotal() AS CostoDirectoParcialTotal
		FROM t_costo_directo cd
				LEFT JOIN t_unidad u ON cd.id_unidad = u.id
		ORDER BY cd.nombre
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_unidad			,
				nombre				,
				cantidad			,
				dedicacion			,
				tiempo_ejecucion	,
				tarifa				,
				
				@operacion
			FROM
				t_costo_directo 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_costo_directo 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_costo_directo WHERE id = @id )		
		BEGIN	
				
			UPDATE t_costo_directo 
				SET id_unidad			= ISNULL (@id_unidad, id_unidad),
					nombre				= ISNULL (@nombre, nombre),
					cantidad			= ISNULL (@cantidad, cantidad),
					dedicacion			= ISNULL (@dedicacion, dedicacion),
					tiempo_ejecucion	= ISNULL (@tiempo_ejecucion, tiempo_ejecucion),
					tarifa				= ISNULL (@tarifa, tarifa)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_costo_directo (
				id_unidad			,
				nombre				,
				cantidad			,
				dedicacion			,
				tiempo_ejecucion	,
				tarifa	
			)
			VALUES(
				@id_unidad			,
				@nombre				,
				@cantidad			,
				@dedicacion			,
				@tiempo_ejecucion	,
				@tarifa
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_costo_directo') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_costo_directo >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_costo_directo >>>'
GO