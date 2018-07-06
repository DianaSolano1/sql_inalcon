create function TotalAIUValor()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select (SUM(c.valor_contrato * (ai.porcentaje / 100)) + dbo.ValorAdmin())
			FROM t_admin_imprevisto ai
				LEFT JOIN t_AIU aiu ON ai.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalAIUValor() as 'subtotal_items';