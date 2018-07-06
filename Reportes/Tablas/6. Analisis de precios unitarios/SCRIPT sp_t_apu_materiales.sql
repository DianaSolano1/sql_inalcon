-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_apu_materiales
IF OBJECT_ID('dbo.sp_t_apu_materiales') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu_materiales
    IF OBJECT_ID('dbo.sp_t_apu_materiales') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu_materiales >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu_materiales >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu_materiales
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_apu			INT				= NULL,
	@id_productos	INT				= NULL,
	@cantidad		NUMERIC (5, 2)	= NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'							--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 			,
			id_apu		,
			id_producto	,
			cantidad
		FROM
			t_apu_material
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'C2'							--> Consulta de materiales en APU
	BEGIN
	
		DECLARE @T_REPORTE_MATERIALES TABLE 
		(
			apu					VARCHAR(5)		NOT NULL,
			materiales			VARCHAR (200)	NOT NULL,
			unidad				VARCHAR (30)	NOT NULL,
			cantidad			NUMERIC (5, 2)	NOT NULL,
			valor_unitario		NUMERIC (18, 2)	NULL,
			factor_desperdicio	NUMERIC (5, 2)	NOT NULL,
			valor				NUMERIC (18, 2)	NULL,
			total				NUMERIC (18, 2)	NULL
		)
		
		INSERT @T_REPORTE_MATERIALES (
				apu,
				materiales,
				unidad,
				cantidad,
				valor_unitario,
				factor_desperdicio)
		SELECT	
			a.codigo AS 'apu',
			p.nombre AS 'materiales',
			u.nombre AS 'unidad',
			am.cantidad AS 'cantidad',
			p.valor AS 'valor_unitario',
			a.factor_desperdicio
		FROM 
			t_apu_material am
			LEFT JOIN t_producto p ON am.id_producto = p.id
			LEFT JOIN t_unidad u ON p.id_unidad = u.id
			LEFT JOIN t_apu a ON am.id_apu = a.ID
		ORDER BY a.codigo DESC

		UPDATE @T_REPORTE_MATERIALES
		SET
			valor	=	dbo.calcularValorMaterial(apu,p.id)
		FROM
			@T_REPORTE_MATERIALES RM
			LEFT JOIN t_producto p ON RM.materiales = p.nombre

		UPDATE @T_REPORTE_MATERIALES
		SET
			total	=	dbo.TotalMaterial(apu)
		FROM
			@T_REPORTE_MATERIALES RM
			LEFT JOIN t_producto p ON RM.materiales = p.nombre
		WHERE
			total	IS NULL

		SELECT * FROM @T_REPORTE_MATERIALES
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 			,
				id_apu		,
				id_producto	,
				cantidad	,
				
				@operacion
			FROM
				t_apu_material 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_apu_material
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_apu_material WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu_material 
				SET id_apu		= ISNULL (@id_apu, id_apu),
					id_producto	= ISNULL (@id_productos, id_producto),
					cantidad	= ISNULL (@cantidad, cantidad)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu_material (
				id_apu			,
				id_producto	,
				cantidad
			)
			VALUES(
				@id_apu			,
				@id_productos	,
				@cantidad
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu_materiales') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu_materiales >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu_materiales >>>'
GO