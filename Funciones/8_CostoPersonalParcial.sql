create function CostoPersonalParcial(@id_cargo INT)
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select 
				(cp.cantidad * (cp.dedicacion / 100) * cp.tiempo_ejecucion * cs.sueldo_basico)
			FROM t_costos_personal cp
				LEFT JOIN t_experiencia ex ON cp.id_experiencia = ex.ID
				LEFT JOIN t_cargo_sueldo cs ON cp.id_experiencia = cs.ID
			WHERE id_cargo = @id_cargo
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.CostoPersonalParcial(5) as 'subtotal_items';