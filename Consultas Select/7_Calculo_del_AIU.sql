--select * from t_AIU;
--select * from t_gastos_campos_oficinas;
--select * from t_gastos_legales;
--select * from t_gastos_personal;
--select * from t_impuestos;
--select * from t_admin_imprevistos;


-- Reporte inicial 
SELECT c.valor_contrato AS 'valor_directo_proyecto'
FROM t_AIU a
LEFT JOIN t_cliente c ON a.id_cliente = c.ID;

-- Reporte Gastos en el campo y oficinas
SELECT	co.id,
		co.descripcion AS 'gastos_campo_oficinas',
		co.valor,
		co.dedicacion,
		co.tiempo_obra,
		(co.valor * (co.dedicacion / 100) * co.tiempo_obra) AS 'total',
		(((co.valor * (co.dedicacion / 100) * co.tiempo_obra) / c.valor_contrato) * 100) AS 'porcentaje'
FROM t_gastos_campos_oficinas co
LEFT JOIN t_AIU aiu ON co.id_AIU = aiu.id
LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID;

-- Reporte Gastos legales
SELECT	gl.id,
		gl.descripcion AS 'gastos_legales',
		gl.valores,
		((gl.valores / cl.valor_contrato) * 100) AS 'porcentaje'
FROM t_gastos_legales gl
LEFT JOIN t_AIU a ON gl.id_AIU = a.id
LEFT JOIN t_cliente cl ON a.id_cliente = cl.ID;

-- Reporte Gastos de personal
SELECT	gp.id,
		cs.nombre AS 'gastos_personal',
		gp.cantidad_empleado AS 'cantidad',
		gp.factor_prestacional,
		gp.valor,
		gp.dedicacion,
		gp.tiempo_obra,
		(gp.cantidad_empleado * gp.factor_prestacional * gp.valor * (gp.dedicacion / 100) * gp.tiempo_obra) AS 'total',
		(((gp.cantidad_empleado * gp.factor_prestacional * gp.valor * (gp.dedicacion / 100) * gp.tiempo_obra) / c.valor_contrato) * 100 ) AS 'porcentaje'
FROM t_gastos_personal gp
LEFT JOIN t_cargo_sueldo cs ON gp.id_empleado = cs.id
LEFT JOIN t_AIU aiu ON gp.id_AIU = aiu.id
LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID;

-- Reporte Impuestos
SELECT	i.id,
		i.descripcion AS 'impuestos',
		((i.porcentaje / 100) * c.valor_contrato) AS 'valores',
		i.porcentaje AS 'porcentaje'
FROM t_impuestos i
LEFT JOIN t_AIU aiu ON i.id_AIU = aiu.id
LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID;

-- Reporte Admisión imprevistos y utilidades
SELECT	ai.id,
		ai.descripcion AS 'admision_imprevistos_utilidades',
		(c.valor_contrato * (ai.porcentaje / 100)) AS 'valores',
		ai.porcentaje AS 'porcentaje'
FROM t_admin_imprevistos ai
LEFT JOIN t_AIU aiu ON ai.id_AIU = aiu.id
LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID;