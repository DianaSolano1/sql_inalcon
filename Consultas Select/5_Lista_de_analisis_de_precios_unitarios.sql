--select * from t_apu;
--select * from t_apu_equipo;
--select * from t_apu_materiales;
--select * from t_apu_transporte_material;
--select * from t_apu_mano_obra;

--select * from t_productos;
--select * from t_cuadrilla;



SELECT	a.codigo AS 'apu',
		a.nombre AS 'descripcion',
		u.nombre AS 'unidad'
FROM t_apu a
LEFT JOIN t_unidades u ON a.id_unidad = u.id;