--SELECT * FROM t_presupuesto_general;
--SELECT * FROM t_subpresupuesto;
--SELECT * FROM t_detalle_subpresupuesto;
--SELECT * FROM t_apu;

-- Reporte presupuesto general
SELECT	pg.item,
		apu.codigo AS 'apu',
		apu.nombre AS 'descripcion',
		u.nombre AS 'unidad',
		'-' AS valor_unitario,
		pg.cantidad,
		'-' AS valor_total
FROM t_presupuesto_general pg
LEFT JOIN t_apu apu ON pg.id_APU = apu.ID
LEFT JOIN t_unidades u ON apu.id_unidad = u.id;

-- Reporte subpresupuesto
SELECT	pg.item,
		s.item,
		apu.codigo AS 'apu',
		apu.nombre AS 'descripcion',
		u.nombre AS 'unidad',
		'-' AS valor_unitario,
		s.cantidad,
		'-' AS valor_total --Suma de todos los valor_total que hay abajo
FROM t_subpresupuesto s
LEFT JOIN t_presupuesto_general pg ON s.id_presupuesto = pg.id
LEFT JOIN t_apu apu ON s.id_APU = apu.ID
LEFT JOIN t_unidades u ON apu.id_unidad = u.id;

-- Reporte detalle subpresupuesto
SELECT	pg.item,
		s.item,
		ds.item,
		apu.codigo AS 'apu',
		apu.nombre AS 'descripcion',
		u.nombre AS 'unidad',
		'-' AS valor_unitario,
		ds.cantidad,
		'-' AS valor_total
FROM t_detalle_subpresupuesto ds
LEFT JOIN t_subpresupuesto s ON ds.id_subpresupuesto = s.ID
LEFT JOIN t_presupuesto_general pg ON ds.id_presupuesto = pg.id
LEFT JOIN t_apu apu ON ds.id_APU = apu.ID
LEFT JOIN t_unidades u ON apu.id_unidad = u.id;