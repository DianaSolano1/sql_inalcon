		----------------------------------------------------------------------------------------------------
		DECLARE @T_PRESUPUESTO_GENERAL TABLE 
		(
			item			INT				NOT NULL,
			apu				VARCHAR(5)		NOT NULL,
			descripcion		VARCHAR(50)		NOT NULL,
			unidad			VARCHAR (30)	NOT NULL,
			valor_unitario	NUMERIC (18, 2)	NULL,
			cantidad		INT				NULL
			--valor_total		VARCHAR(5)		NULL
		)

		INSERT @T_PRESUPUESTO_GENERAL (
				item,
				apu,
				descripcion,
				unidad,
				valor_unitario,
				cantidad
				--valor_total
			)
		SELECT	pg.item,
				apu.codigo AS 'apu',
				apu.nombre AS 'descripcion',
				u.nombre AS 'unidad',
				2 AS valor_unitario,
				pg.cantidad
				-- AS valor_total
		FROM t_presupuesto_general pg
				LEFT JOIN t_apu apu ON pg.id_APU = apu.ID
				LEFT JOIN t_unidades u ON apu.id_unidad = u.id
		GROUP BY
			pg.item		,
			apu.codigo	,
			apu.nombre	,
			u.nombre	,
			pg.cantidad
		ORDER BY pg.item DESC

		SELECT * FROM @T_PRESUPUESTO_GENERAL


		----------------------------------------------------------------------------------------------------
		DECLARE @T_SUBPRESUPUESTO TABLE 
		(
			item			INT				NOT NULL,
			subitem			INT				NOT NULL,
			apu				VARCHAR(5)		NOT NULL,
			descripcion		VARCHAR(50)		NOT NULL,
			unidad			VARCHAR (30)	NOT NULL,
			valor_unitario	NUMERIC (18, 2)	NULL,
			cantidad		INT				NULL
			--valor_total		VARCHAR(5)		NULL
		)

		INSERT @T_SUBPRESUPUESTO (
				item,
				subitem,
				apu,
				descripcion,
				unidad,
				valor_unitario,
				cantidad
			)
		SELECT	pg.item,
				s.item,
				apu.codigo AS 'apu',
				apu.nombre AS 'descripcion',
				u.nombre AS 'unidad',
				2 AS valor_unitario,
				s.cantidad
				--'-' AS valor_total --Suma de todos los valor_total que hay abajo
		FROM t_subpresupuesto s
				LEFT JOIN t_presupuesto_general pg ON s.id_presupuesto = pg.id
				LEFT JOIN t_apu apu ON s.id_APU = apu.ID
				LEFT JOIN t_unidades u ON apu.id_unidad = u.id
		GROUP BY
			pg.item		,
			s.item		,
			apu.codigo	,
			apu.nombre	,
			u.nombre	,
			s.cantidad
		HAVING COUNT(*) >= 1
		ORDER BY pg.item DESC

		SELECT * FROM @T_SUBPRESUPUESTO

		----------------------------------------------------------------------------------------------------
		DECLARE @T_DETALLE_SUBPRESUPUESTO TABLE 
		(
			item			INT				NOT NULL,
			subitem			INT				NOT NULL,
			detalle_subitem	INT				NOT NULL,
			apu				VARCHAR(5)		NOT NULL,
			descripcion		VARCHAR(50)		NOT NULL,
			unidad			VARCHAR (30)	NOT NULL,
			valor_unitario	NUMERIC (18, 2)	NULL,
			cantidad		INT				NULL
			--valor_total		VARCHAR(5)		NULL
		)

		INSERT @T_DETALLE_SUBPRESUPUESTO (
				item,
				subitem,
				detalle_subitem,
				apu,
				descripcion,
				unidad,
				valor_unitario,
				cantidad
				--valor_total
			)
		SELECT	pg.item,
				s.item,
				ds.item,
				apu.codigo AS 'apu',
				apu.nombre AS 'descripcion',
				u.nombre AS 'unidad',
				2 AS valor_unitario,
				ds.cantidad
				-- AS valor_total
		FROM t_detalle_subpresupuesto ds
				LEFT JOIN t_subpresupuesto s ON ds.id_subpresupuesto = s.ID
				LEFT JOIN t_presupuesto_general pg ON ds.id_presupuesto = pg.id
				LEFT JOIN t_apu apu ON ds.id_APU = apu.ID
				LEFT JOIN t_unidades u ON apu.id_unidad = u.id
		GROUP BY
			pg.item			,
			s.item			,
			ds.item			,
			apu.codigo		,
			apu.nombre		,
			u.nombre		,
			ds.cantidad		
		ORDER BY pg.item DESC

		SELECT * FROM @T_DETALLE_SUBPRESUPUESTO