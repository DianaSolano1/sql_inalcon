IF OBJECT_ID('dbo.sp_lista_insumos') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.sp_lista_insumos
	IF OBJECT_ID('dbo.sp_lista_insumos') IS NOT NULL
		PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_lista_insumos>>>'
	ELSE
		PRINT '<<< DROPPED PROCEDURE dbo.sp_lista_insumos >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_lista_insumos
(
	@operacion			VARCHAR(5)				,

	@id					VARCHAR(30)				,
	@descripcion		VARCHAR (200)			,
	@unidad				VARCHAR (30)			,
	@antes_iva			NUMERIC (18, 2)			,
	@aplica_iva			BIT						,
	@procedencia		VARCHAR (30)			,

	-- Valor calculado
	@valor_total		NUMERIC (20, 2)	= NULL	
)
WITH ENCRYPTION

AS

	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	----------------------------------------------------------------------
	
	IF @operacion = 'C1'							--> Reporte de insumos
	BEGIN
		
		DECLARE @T_REPORTE_INSUMOS TABLE 
		(
			descripcion		VARCHAR (200)	NOT NULL	,
			unidad			VARCHAR(30)		NOT NULL	,
			antes_iva		NUMERIC (18, 2)	NOT NULL	,
			aplica_iva		BIT				NOT NULL	,
			valor_total		NUMERIC (18, 2)	NOT NULL	,
			procedencia		VARCHAR (30)	NOT NULL	
		)
		----------------------------------------------------------------------------------------------------
		-- GUARDA LOS DATOS PARA LA TABLA
		INSERT @T_REPORTE_INSUMOS (descripcion, unidad, antes_iva, aplica_iva, valor_total, procedencia)
		SELECT  p.nombre AS 'descripcion',
				u.nombre AS 'unidad',
				p.valor AS 'antes_iva',
				p.sn_iva AS 'aplica_iva',
				dbo.fc_detectarIva(p.id)	AS 'valor_total',
				pc.nombre AS 'procedencia'
		FROM	t_productos p
				LEFT JOIN t_unidades u ON p.id_unidad = u.id
				LEFT JOIN t_procedencia pc ON p.id_procedencia = pc.id
				LEFT JOIN t_legal l ON p.id_iva = l.id
		GROUP BY
			p.id		,
			p.nombre	,
			u.nombre	,
			p.valor		,
			p.sn_iva	,
			l.valor		,
			pc.nombre
		HAVING COUNT(*) >= 1
		ORDER BY p.nombre DESC
		
	END ELSE

IF OBJECT_ID('dbo.sp_lista_insumos') IS NOT NULL
	PRINT '<<< CREATED PROCEDURE dbo.sp_lista_insumos >>>'
ELSE
	PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_lista_insumos >>>'
GO