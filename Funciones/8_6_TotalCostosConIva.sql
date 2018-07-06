create function TotalCostosMasIva()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select 
				(dbo.TotalCostosInterventoria() * (l.valor / 100))
			from t_legal l
			where
				l.nombre = 'Iva'
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalCostosMasIva() as 'subtotal_items';