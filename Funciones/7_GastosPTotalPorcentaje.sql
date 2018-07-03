alter function GastosPTotalPorcentaje()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select SUM(dbo.GastosPPorcentaje(gp.id))
			from t_gastos_personal gp
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.GastosPTotalPorcentaje() as 'subtotal_porcentajes';