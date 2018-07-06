create function TotalCostos()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select 
				(dbo.TotalCostosInterventoria() + dbo.TotalCostosMasIva())
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalCostos() as 'subtotal_items';