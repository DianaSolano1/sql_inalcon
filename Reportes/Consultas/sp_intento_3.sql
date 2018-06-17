alter procedure sp_cuadrillas
as
begin
	
	SELECT	cdet.id_jornal_empleado,
				cdet.descripcion AS 'descripcion_cuadrillas',
				cdet.cantidad_oficial,
				cdet.cantidad_ayudante,
				( (cdet.cantidad_oficial * (select tje.valor_jornal from v_jornal_empleado tje
											where tje.id = cdet.id_jornal_empleado
											and tje.cargo = 1) ) +
				(cdet.cantidad_ayudante * (select tje.valor_jornal from v_jornal_empleado tje
											where tje.id = cdet.id_jornal_empleado
											and tje.cargo = 0)) )
											
		FROM t_cuadrilla_detalle cdet
				LEFT JOIN t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
		GROUP BY
			cdet.id_jornal_empleado	,
			cdet.descripcion		,
			cdet.cantidad_oficial	,
			cdet.cantidad_ayudante
		HAVING COUNT(*) >= 1
		ORDER BY cdet.descripcion DESC
	

end

go 

exec sp_cuadrillas


select * from v_jornal_empleado tje
join t_cuadrilla_detalle cdet on tje.id = cdet.id_jornal_empleado
where tje.cargo = 0