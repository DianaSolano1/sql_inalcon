--select * from t_cuadrilla;
--select * from t_jornal_empleado;
--select * from t_cuadrilla_detalle;
--select * from t_cliente;
--select * from t_legal;


-- Reporte de una sola linea para la cuadrilla
SELECT	l.valor AS 'salario_minimo',
		c.dias_labor AS 'dias_laborales',
		c.horas_dia
FROM t_cuadrilla c
LEFT JOIN t_legal l ON c.id_salrio_minimo = l.id;

-- Reporte primera tabla cuadrilla
SELECT	je.descripcion,
		je.porcentaje,
		cl.valor AS 'salario_minimo',
		cd.dias_labor AS 'dias_laborales',
		((1 + (je.porcentaje / 100)) * (cl.valor / cd.dias_labor)) AS 'valor_jornal',
		--(1 + (je.porcentaje / 100)) AS 'porcentaje+1',
		--(cl.valor / cd.dias_labor) AS 'salario/dias',
		je.sn_ayudante AS 'cargo'
FROM t_jornal_empleado je
LEFT JOIN t_cuadrilla cd ON je.id_cuadrilla = cd.id
LEFT JOIN t_legal cl ON cd.id_salrio_minimo = cl.id;

-- Reporte segunda tabla cuadrilla
SELECT	cdet.id_jornal_empleado,
		cdet.descripcion AS 'descripcion_cuadrillas',
		cdet.cantidad_oficial,
		cdet.cantidad_ayudante
		--Valor jornal cuadrilla
		--Valor jornal cuadrilla + prestaciones
		--Valor cuadrilla/hora con prestaciones
FROM t_cuadrilla_detalle cdet
LEFT JOIN t_jornal_empleado je ON cdet.id_jornal_empleado = je.id;