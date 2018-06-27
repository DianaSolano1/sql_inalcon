alter function TotalManoObra()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select sum((p.valor * atm.tarifa)) 
			from t_apu_transporte_material atm
				LEFT JOIN t_productos p ON atm.id_productos = p.id
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalManoObra() as 'total_mano_obra';