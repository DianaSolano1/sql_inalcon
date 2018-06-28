alter function GastosPPorcentaje(@id INT)
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select ((dbo.GastosPTotal(gp.id) / c.valor_contrato) * 100 )
			from t_gastos_personal gp
				LEFT JOIN t_cargo_sueldo cs ON gp.id_empleado = cs.id
				LEFT JOIN t_AIU aiu ON gp.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
			where gp.id = @id
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.GastosPPorcentaje(10) as 'subtotal_porcentajes';