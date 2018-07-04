		DECLARE @T_REPORTE_INSUMOS TABLE 
		(
			descripcion		VARCHAR (200)	NOT NULL	,
			unidad			VARCHAR(30)		NOT NULL	,
			antes_iva		NUMERIC (18, 2)	NOT NULL	,
			aplica_iva		BIT				NOT NULL	,
			valor_total		NUMERIC (18, 2)	NOT NULL	,
			procedencia		VARCHAR (30)	NOT NULL	
		)
		INSERT @T_REPORTE_INSUMOS (descripcion, unidad, antes_iva, aplica_iva, valor_total, procedencia)
		SELECT  
			p.nombre AS 'descripcion',
			u.nombre AS 'nombre_unidad',
			p.valor AS 'valor_directo',
			p.sn_iva,
			dbo.fc_detectarIva(p.id) AS 'valor_total',
			pc.nombre AS 'nombre_procedencia'
		FROM	
			t_productos p
			LEFT JOIN t_unidad u ON p.id_unidad = u.id
			LEFT JOIN t_procedencia pc ON p.id_procedencia = pc.id
		ORDER BY p.nombre DESC

		SELECT * FROM @T_REPORTE_INSUMOS