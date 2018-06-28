create view v_jornal_empleado
as
	SELECT	je.id,
				je.descripcion,
				je.porcentaje,
				cl.valor AS 'salario_minimo',
				cd.dias_labor AS 'dias_laborales',
				((1 + (je.porcentaje / 100)) * (cl.valor / cd.dias_labor)) AS 'valor_jornal',
				--(1 + (je.porcentaje / 100)) AS 'porcentaje+1',
				--(cl.valor / cd.dias_labor) AS 'salario/dias',
				je.sn_ayudante AS 'cargo'
		FROM t_jornal_empleado je
				LEFT JOIN t_cuadrilla cd ON je.id_cuadrilla = cd.id
				LEFT JOIN t_legal cl ON cd.id_salrio_minimo = cl.id
		GROUP BY
			je.id,
			je.descripcion	,
			je.porcentaje	,
			cl.valor		,
			cd.dias_labor	,
			je.sn_ayudante
		HAVING COUNT(*) >= 1