create function ImpuestosTotalPorcentajes()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select SUM(i.porcentaje)
			from t_impuesto i
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.ImpuestosTotalPorcentajes() as 'subtotal_items';