alter function calcularFactorMultiplicadorTotal()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
		(select sum(tfd.porcentaje) from t_factor_base tfd )
		+
		(select dbo.calcularFactorMultiplicador('C'))
	);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.calcularFactorMultiplicadorTotal() as 'factor_prestacional';