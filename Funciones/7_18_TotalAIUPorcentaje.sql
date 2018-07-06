create function TotalAIUPorcentaje()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select (SUM(ai.porcentaje) + dbo.PorcentajeAdmin())
			FROM t_admin_imprevisto ai
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalAIUPorcentaje() as 'subtotal_items';