alter function TotalManoObra(@apu VARCHAR(5))
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select sum(dbo.ManoObraValor(a.codigo,cdet.id,amo.ID)) 
			from t_cuadrilla_detalle cdet
				left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
				left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
				left join t_apu a ON a.ID = amo.id_apu
			where
				a.codigo = @apu
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalManoObra('0001') as 'total_mano_obra';