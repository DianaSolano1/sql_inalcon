alter function ManoObraJornal()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select (
				-- para el de oficial
				(cdet.cantidad_oficial * dbo.ObtenerValorJornal(cdet.id_jornal_empleado,  1))

				+
				-- para el de ayudante
				(cdet.cantidad_ayudante * dbo.ObtenerValorJornal(cdet.id_jornal_empleado, 0))

			)
			from t_cuadrilla_detalle cdet
				left join t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
				left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
				left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
				left join t_apu a ON a.ID = amo.id_apu
			where
				a.ID = amo.id_apu
			/*select jornal + jornal_total
			from @T_REPORTE_MANO_OBRA*/
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.ManoObraJornal() as 'jornal';