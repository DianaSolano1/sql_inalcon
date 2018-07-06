create function GastosCOSTIValor()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select SUM(dbo.TotalGastosCO(co.id))
			from t_gasto_campo_oficina co
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.GastosCOSTIValor() as 'subtotal_valor';