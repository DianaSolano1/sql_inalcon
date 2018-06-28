alter function GastosPTotal(@id INT)
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select (gp.cantidad_empleado * gp.factor_prestacional * gp.valor * (gp.dedicacion / 100) * gp.tiempo_obra)
			from t_gastos_personal gp
			where gp.id = @id
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.GastosPTotal(10) as 'subtotal_porcentajes';