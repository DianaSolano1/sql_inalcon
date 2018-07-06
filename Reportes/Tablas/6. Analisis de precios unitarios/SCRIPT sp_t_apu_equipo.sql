-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_apu_equipo
IF OBJECT_ID('dbo.sp_t_apu_equipo') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu_equipo
    IF OBJECT_ID('dbo.sp_t_apu_equipo') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu_equipo >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu_equipo >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu_equipo
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_apu			INT				= NULL,
	@id_productos	INT				= NULL,
	@cantidad		NUMERIC (5, 2)	= NULL,
	@rendimiento	NUMERIC (5, 2)	= NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'					--> Seleccion de tabla completa o por ID				
	BEGIN
	
		SELECT 
			id 				,
			id_apu			,
			id_producto		,
			cantidad		,
			rendimiento
		FROM
			t_apu_equipo
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END

	END ELSE	

	IF @operacion = 'C2'					--> Consulta de equipos en APU
	BEGIN
	
		DECLARE @T_REPORTE_EQUIPO TABLE 
		(
			apu			VARCHAR(5)		NOT NULL,
			equipo		VARCHAR (200)	NOT NULL,
			unidad		VARCHAR (30)	NOT NULL,
			cantidad	NUMERIC (5, 2)	NOT NULL,
			tarifa_dia	NUMERIC (18, 2)	NULL,
			rendimiento	NUMERIC (5, 2)	NOT NULL,
			valor		NUMERIC (18, 2)	NOT NULL,
			total		NUMERIC (18, 2)	NULL
		)

		INSERT @T_REPORTE_EQUIPO (
				apu,
				equipo,
				unidad,
				cantidad,
				tarifa_dia,
				rendimiento,
				valor)
		SELECT	a.codigo AS 'apu',
				p.nombre AS 'equipo',
				u.nombre AS 'unidad',
				ae.cantidad,
				p.valor AS 'tarifa_dia',
				ae.rendimiento,
				(p.valor * ae.rendimiento) AS valor
		FROM t_apu_equipo ae
				LEFT JOIN t_producto p ON ae.id_producto = p.id
				LEFT JOIN t_unidad u ON p.id_unidad = u.id
				LEFT JOIN t_apu a ON ae.id_apu = a.ID
		ORDER BY a.codigo DESC

		UPDATE @T_REPORTE_EQUIPO
		SET
			total	=	dbo.TotalEquipo(apu)
		FROM
			@T_REPORTE_EQUIPO RE
		WHERE
			total	IS NULL

		SELECT * FROM @T_REPORTE_EQUIPO

	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_apu			,
				id_producto		,
				cantidad		,
				rendimiento		,
				
				@operacion
			FROM
				t_apu_equipo 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_apu_equipo 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_apu_equipo WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu_equipo 
				SET id_apu			= ISNULL (@id_apu, id_apu),
					id_producto		= ISNULL (@id_productos, id_producto),
					cantidad		= ISNULL (@cantidad, cantidad),
					rendimiento		= ISNULL (@rendimiento, rendimiento)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu_equipo (
				id_apu			,
				id_producto		,
				cantidad		,
				rendimiento
			)
			VALUES(
				@id_apu			,
				@id_productos	,
				@cantidad		,
				@rendimiento
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu_equipo') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu_equipo >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu_equipo >>>'
GO