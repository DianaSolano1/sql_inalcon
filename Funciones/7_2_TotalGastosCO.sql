create function TotalGastosCO(@id INT)
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select (co.valor * (co.dedicacion / 100) * co.tiempo_obra)
			from t_gasto_campo_oficina co
			where co.id = @id
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalGastosCO(3) as 'total_mano_obra';