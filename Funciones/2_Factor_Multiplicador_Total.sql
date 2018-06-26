alter function calcularFactorMultiplicadorTotal()
returns float 
as
begin
	declare @valor float;

	set @valor = (select sum(tfd.porcentaje) from t_factor_detalle tfd );

	return @valor;
end

go

select * from t_factor_detalle;

select dbo.calcularFactorMultiplicadorTotal() as 'Total';