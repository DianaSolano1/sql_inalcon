create function PorcentajeAdmin()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select 
				dbo.GastosCOSTIPorcentaje() +
				dbo.GastosLSTIPorcentajes() +
				dbo.GastosPTotalPorcentaje() +
				dbo.ImpuestosTotalPorcentajes()
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.PorcentajeAdmin() as 'subtotal_items';