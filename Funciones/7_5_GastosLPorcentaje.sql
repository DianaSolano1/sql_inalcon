create function GastosLPorcentaje(@id INT)
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select ((gl.valores / cl.valor_contrato) * 100)
			from t_gasto_legal gl
				LEFT JOIN t_AIU a ON gl.id_AIU = a.id
				LEFT JOIN t_cliente cl ON a.id_cliente = cl.ID
			where gl.id = @id
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.GastosLPorcentaje(17) as 'total_mano_obra';