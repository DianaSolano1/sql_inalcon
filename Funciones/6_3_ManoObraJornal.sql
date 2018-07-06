alter function ManoObraJornal(@id_apu VARCHAR(5), @id_cuadrilla INT)
returns float 
as
begin
	declare @valor float;

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
				a.codigo = @id_apu
				AND cdet.id = @id_cuadrilla
			group by
				cdet.cantidad_ayudante,
				cdet.cantidad_oficial,
				cdet.id_jornal_empleado
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.ManoObraJornal('0001',1) as 'jornal';