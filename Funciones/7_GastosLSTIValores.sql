create function GastosLSTIValores()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select SUM(gl.valores)
			from t_gastos_legales gl
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.GastosLSTIValores() as 'subtotal_valores';