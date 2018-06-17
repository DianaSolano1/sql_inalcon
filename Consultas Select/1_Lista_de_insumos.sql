--select * from t_unidades;
--select * from t_procedencia;
--select * from t_legal;
--select * from t_productos;



--SELECT	p.nombre AS 'descripcion',
--		u.nombre AS 'unidad', 
--		p.valor AS 'antes_iva', 
--		pc.nombre AS 'procedencia'
--FROM t_productos p
--LEFT JOIN t_unidades u ON p.id_unidad = u.id
--LEFT JOIN t_procedencia pc ON p.id_procedencia = pc.id;



SELECT  p.nombre AS 'descripcion',
		u.nombre AS 'unidad',
		p.valor AS 'antes_iva',
		p.sn_iva AS 'aplica_iva',
		(p.valor * (1 + (l.valor / 100))) AS 'valor_total',
		pc.nombre AS 'procedencia'
FROM t_productos p
LEFT JOIN t_unidades u ON p.id_unidad = u.id
LEFT JOIN t_procedencia pc ON p.id_procedencia = pc.id
LEFT JOIN t_legal l ON p.id_iva = l.id;