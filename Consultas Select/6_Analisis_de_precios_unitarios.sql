--select * from t_apu;
--select * from t_apu_equipo;
--select * from t_apu_materiales;
--select * from t_apu_transporte_material;
--select * from t_apu_mano_obra;

--select * from t_productos;
--select * from t_cuadrilla;
--select * from t_cuadrilla_detalle;


-- Reporte inicial APU
SELECT	a.codigo AS 'apu',
		a.nombre AS 'descripcion',
		u.nombre AS 'unidad',
		a.factor_hm,
		a.factor_desperdicio
		--Costos directos
FROM t_apu a
LEFT JOIN t_unidades u ON a.id_unidad = u.id;

-- Reporte equipo
SELECT	a.codigo AS 'apu',
		p.nombre AS 'equipo',
		u.nombre AS 'unidad',
		ae.cantidad,
		p.valor AS 'tarifa_dia',
		ae.rendimiento,
		(p.valor * ae.rendimiento) AS valor
FROM t_apu_equipo ae
LEFT JOIN t_productos p ON ae.id_productos = p.id
LEFT JOIN t_unidades u ON p.id_unidad = u.id
LEFT JOIN t_apu a ON ae.id_apu = a.ID;

-- Reporte Materiales
SELECT	a.codigo AS 'apu',
		p.nombre AS 'materiales',
		u.nombre AS 'unidad',
		am.cantidad AS 'cantidad',
		p.valor AS 'valor_unitario',
		a.factor_desperdicio,
		(am.cantidad * p.valor * (1 + (a.factor_desperdicio / 100))) AS 'valor',
		(1 + (a.factor_desperdicio / 100)) AS 'porcentaje'
FROM t_apu_materiales am
LEFT JOIN t_productos p ON am.id_productos = p.id
LEFT JOIN t_unidades u ON p.id_unidad = u.id
LEFT JOIN t_apu a ON am.id_apu = a.ID;

-- Reporte Transporte del material
SELECT	a.codigo AS 'apu',
		p.nombre AS 'transporte_material',
		u.nombre AS 'vol_peso_cant',
		atm.distancia,
		p.valor AS 'm3_km',
		atm.tarifa,
		(p.valor * atm.tarifa) AS 'valor_unitario'
FROM t_apu_transporte_material atm
LEFT JOIN t_productos p ON atm.id_productos = p.id
LEFT JOIN t_unidades u ON p.id_unidad = u.id
LEFT JOIN t_apu a ON atm.id_apu = a.ID;

-- Reporte Mano de obra
SELECT	a.codigo AS 'apu',
		cd.descripcion AS 'mano_obra',
		-- Jornal
		-- Factor Prestacional
		-- Jornal Total
		amo.rendimiento
		-- valor
FROM t_apu_mano_obra amo
LEFT JOIN t_cuadrilla c ON amo.id_cuadrilla = c.id
LEFT JOIN t_cuadrilla_detalle cd ON c.id = cd.id_cuadrilla
LEFT JOIN t_apu a ON amo.id_apu = a.ID;