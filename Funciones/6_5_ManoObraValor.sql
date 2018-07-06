alter function ManoObraValor(@id_apu VARCHAR(5), @id_cuadrilla INT, @id_apu_mano_obra INT)
returns float 
as
begin
	declare @valor float;

	set @valor = (
			select ( dbo.ManoObraJornalTotal(a.codigo,cdet.id) / amo.rendimiento)
			from t_cuadrilla_detalle cdet
				left join t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
				left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
				left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
				left join t_apu a ON a.ID = amo.id_apu
			where
				a.codigo = @id_apu
				AND cdet.id = @id_cuadrilla
				AND amo.ID = @id_apu_mano_obra
		);

	return @valor;
end

go

--select * from t_factor_base;

select	dbo.ManoObraValor('0001',1,2) as 'jornal';