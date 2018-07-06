-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_apu_transporte_material
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
	
	IF @operacion = 'C1'							--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 				,
			id_apu			,
			id_producto		,
			distancia		,
			tarifa
		FROM
			t_apu_transporte_material
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE
	
	IF @operacion = 'C2'							--> Consulta de transporte de materiales en APU
	BEGIN
	
		DECLARE @T_REPORTE_TRANSPORTE_MATERIALES TABLE 
		(
			apu						VARCHAR(5)		NOT NULL,
			transporte_materiales	VARCHAR (200)	NOT NULL,
			vol_peso_cant			VARCHAR (30)	NOT NULL,
			distancia				NUMERIC (10, 2)	NOT NULL,
			m3_km					NUMERIC (18, 2)	NOT NULL,
			tarifa					NUMERIC (10, 2)	NOT NULL,
			valor_unitario			NUMERIC (20, 2)	NOT NULL,
			total					NUMERIC (18, 2)	NULL
		)
		
		INSERT @T_REPORTE_TRANSPORTE_MATERIALES (
				apu,
				transporte_materiales,
				vol_peso_cant,
				distancia,
				m3_km,
				tarifa,
				valor_unitario)
		SELECT	
			a.codigo AS 'apu',
			p.nombre AS 'transporte_material',
			u.nombre AS 'vol_peso_cant',
			atm.distancia,
			p.valor AS 'm3_km',
			atm.tarifa,
			(p.valor * atm.tarifa) AS 'valor_unitario'
		FROM 
			t_apu_transporte_material atm
			LEFT JOIN t_producto p ON atm.id_producto = p.id
			LEFT JOIN t_unidad u ON p.id_unidad = u.id
			LEFT JOIN t_apu a ON atm.id_apu = a.ID
		ORDER BY a.codigo DESC

		UPDATE @T_REPORTE_TRANSPORTE_MATERIALES
		SET
			total	=	dbo.TotalTransporteMaterial(apu)
		FROM
			@T_REPORTE_TRANSPORTE_MATERIALES RTM
		WHERE
			total	IS NULL

		SELECT * FROM @T_REPORTE_TRANSPORTE_MATERIALES

	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_apu			,
				id_producto		,
				distancia		,
				tarifa			,
				
				@operacion
			FROM
				t_apu_transporte_material 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_apu_transporte_material 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_apu_transporte_material WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu_transporte_material 
				SET id_apu			= ISNULL (@id_apu, id_apu),
					id_producto		= ISNULL (@id_productos, id_producto),
					distancia		= ISNULL (@distancia, distancia),
					tarifa			= ISNULL (@tarifa, tarifa)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu_transporte_material (
				id_apu			,
				id_producto		,
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