alter function CostoDirectoParcialTotal()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select 
				SUM(dbo.CostoDirectoParcial(cd.id))
			FROM t_costos_directos cd
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.CostoDirectoParcialTotal() as 'subtotal_items';