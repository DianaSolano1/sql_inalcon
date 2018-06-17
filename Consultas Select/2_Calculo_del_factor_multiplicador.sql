--select * from t_factor_base;
--select * from t_factor_subitem;
--select * from t_factor_detalle;


SELECT	b.item AS 'item_capitulo',
		b.nombre AS 'capitulo',
		b.porcentaje AS 'porcentaje_capitulo',
		s.item AS 'item_subcapitulo',
		s.nombre AS 'subcapitulo',
		s.porcentaje AS 'porcentaje_subcapitulo',
		d.nombre AS 'item',
		d.porcentaje AS 'porcentaje_item'
FROM t_factor_base b
LEFT JOIN t_factor_subitem s ON b.ID = s.id_factor_base
LEFT JOIN t_factor_detalle d ON s.ID = d.id_factor_subitem;