alter function PorcentajeGastosCO(@id INT)
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select (((co.valor * (co.dedicacion / 100) * co.tiempo_obra) / c.valor_contrato) * 100)
			from t_gastos_campos_oficinas co
				LEFT JOIN t_AIU aiu ON co.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
			where co.id = @id
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.PorcentajeGastosCO(3) as 'total_mano_obra';