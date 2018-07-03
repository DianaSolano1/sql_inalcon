alter function ImpuestosSTI()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select SUM(((i.porcentaje / 100) * c.valor_contrato))
			from t_impuestos i
				LEFT JOIN t_AIU aiu ON i.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.ImpuestosSTI() as 'subtotal_items';