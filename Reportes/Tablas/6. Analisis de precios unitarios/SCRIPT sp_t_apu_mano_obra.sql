---------------------------------------------------------------------------
-- sp_t_apu_mano_obra
IF OBJECT_ID('dbo.sp_t_apu_mano_obra') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu_mano_obra
    IF OBJECT_ID('dbo.sp_t_apu_mano_obra') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu_mano_obra >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu_mano_obra >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu_mano_obra
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_apu			INT				= NULL,
	@id_cuadrilla	INT				= NULL,
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
			id_cuadrilla	,
			rendimiento
		FROM
			t_apu_mano_obra
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END

	END ELSE	

	IF @operacion = 'C2'					--> Consulta de mano de obra en APU
	BEGIN
	
		DECLARE @T_REPORTE_MANO_OBRA TABLE 
		(
			apu					VARCHAR(5)		NOT NULL,
			mano_obra			VARCHAR (200)	NULL,
			jornal				NUMERIC (18, 2)	NULL,
			factor_prestacional	NUMERIC (5, 2)	NULL,
			jornal_total		NUMERIC (18, 2)	NULL,
			redimiento			NUMERIC (5, 2)	NOT NULL,
			valor				NUMERIC (18, 2) NULL,
			total				NUMERIC (18, 2)	NULL
		)
		
		INSERT @T_REPORTE_MANO_OBRA (
				apu,
				mano_obra,
				redimiento)
		SELECT	a.codigo AS 'apu',
				cd.descripcion AS 'mano_obra',
				amo.rendimiento
		FROM t_apu_mano_obra amo
				LEFT JOIN t_cuadrilla c ON amo.id_cuadrilla = c.id
				LEFT JOIN t_cuadrilla_detalle cd ON c.id = cd.id_cuadrilla
				LEFT JOIN t_apu a ON amo.id_apu = a.ID
		GROUP BY
			a.codigo		,
			cd.descripcion	,
			amo.rendimiento	
		ORDER BY a.codigo DESC

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			jornal	=	dbo.ManoObraJornal(a.codigo,cdet.id)
		FROM
			@T_REPORTE_MANO_OBRA RMO
			LEFT JOIN t_cuadrilla_detalle cdet ON RMO.mano_obra = cdet.descripcion
			left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
			left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
			left join t_apu a ON a.ID = amo.id_apu
		WHERE
			jornal	IS NULL

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			factor_prestacional	=	(dbo.calcularFactorMultiplicadorTotal() / 100)
		FROM
			@T_REPORTE_MANO_OBRA RMO
		WHERE
			factor_prestacional	IS NULL

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			jornal_total	=	dbo.ManoObraJornalTotal(a.codigo,cdet.id)
		FROM
			@T_REPORTE_MANO_OBRA RMO
			LEFT JOIN t_cuadrilla_detalle cdet ON RMO.mano_obra = cdet.descripcion
			left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
			left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
			left join t_apu a ON a.ID = amo.id_apu
		WHERE
			jornal_total	IS NULL

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			valor	=	dbo.ManoObraValor(a.codigo,cdet.id,amo.ID)
		FROM
			@T_REPORTE_MANO_OBRA RMO
			--LEFT JOIN t_productos p ON RTM.transporte_materiales = p.nombre
			LEFT JOIN t_cuadrilla_detalle cdet ON RMO.mano_obra = cdet.descripcion
			left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
			left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
			left join t_apu a ON a.ID = amo.id_apu
		WHERE
			valor	IS NULL

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			total	=	dbo.TotalManoObra(apu)
		FROM
			@T_REPORTE_MANO_OBRA RMO
		WHERE
			total	IS NULL

		SELECT * FROM @T_REPORTE_MANO_OBRA

	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_apu			,
				id_cuadrilla	,
				rendimiento		,
				
				@operacion
			FROM
				t_apu_mano_obra 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_apu_mano_obra 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_apu_mano_obra WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu_mano_obra 
				SET id_apu			= ISNULL (@id_apu, id_apu),
					id_cuadrilla	= ISNULL (@id_cuadrilla, id_cuadrilla),
					rendimiento		= ISNULL (@rendimiento, rendimiento)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu_mano_obra (
				id_apu			,
				id_cuadrilla	,
				rendimiento
			)
			VALUES(
				@id_apu			,
				@id_cuadrilla	,
				@rendimiento
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu_mano_obra') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu_mano_obra >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu_mano_obra >>>'
GO