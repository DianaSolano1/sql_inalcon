create function TotalPersonal()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select 
				((dbo.CostoPersonalSubTotal()) * 2)
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalPersonal() as 'subtotal_items';