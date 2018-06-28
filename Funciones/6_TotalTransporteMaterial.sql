alter function TotalTransporteMaterial(@id_apu VARCHAR(5))
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select sum((p.valor * atm.tarifa)) 
			from t_apu_transporte_material atm
				LEFT JOIN t_productos p ON atm.id_productos = p.id
				LEFT JOIN t_apu a ON atm.id_apu = a.ID
			where
				atm.id_apu = @id_apu
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalTransporteMaterial('001') as 'total_transporte_materiales';