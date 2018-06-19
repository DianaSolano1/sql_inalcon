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
				--@aplica_iva,
				p.sn_iva AS 'aplica_iva',
				--(p.valor * (1 + (l.valor / 100))) AS 'valor_total',
				dbo.fc_detectarIva(p.id)	as 'valor_total',
				--(p.valor * (1 + (l.valor / 100))) AS 'valor_total',
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

		SELECT * FROM @T_REPORTE_INSUMOS