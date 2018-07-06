create function CostoPersonalSubTotal()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select 
				SUM(dbo.CostoPersonalParcial(cs.ID))
			FROM t_cargo_sueldo cs
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.CostoPersonalSubTotal() as 'subtotal_items';