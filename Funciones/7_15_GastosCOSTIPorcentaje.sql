create function GastosCOSTIPorcentaje()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select SUM(dbo.PorcentajeGastosCO(co.id))
			from t_gasto_campo_oficina co
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.GastosCOSTIPorcentaje() as 'subtotal_porcentaje';