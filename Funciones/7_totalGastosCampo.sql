alter function totalGastosCampo()
	returns int
as begin
	declare @valor float


	set @valor = (
				select 
					(co.valor * (co.dedicacion / 100) * co.tiempo_obra)
				from t_gastos_campos_oficinas co
					LEFT JOIN t_AIU aiu ON co.id_AIU = aiu.id
					LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
			);

	return @valor

end

go

select dbo.totalGastosCampo() as 'total';