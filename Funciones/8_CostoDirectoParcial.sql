alter function CostoDirectoParcial(@id INT)
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select 
				(cd.tarifa * (cd.dedicacion / 100) * cd.tiempo_ejecucion * cd.cantidad)
			FROM t_costos_directos cd
			WHERE cd.id = @id
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.CostoDirectoParcial(4) as 'subtotal_items';