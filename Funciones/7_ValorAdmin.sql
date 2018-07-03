alter function ValorAdmin()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select 
				dbo.GastosCOSTIValor() +
				dbo.GastosLSTIValores() +
				dbo.GastosPSTI() +
				dbo.ImpuestosSTI()
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.ValorAdmin() as 'subtotal_items';