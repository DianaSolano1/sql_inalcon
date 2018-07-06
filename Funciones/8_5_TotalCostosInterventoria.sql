create function TotalCostosInterventoria()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select 
				(dbo.CostoDirectoParcialTotal() + dbo.TotalPersonal())
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalCostosInterventoria() as 'subtotal_items';