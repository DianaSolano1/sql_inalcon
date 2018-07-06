create function TotalMaterial(@id_apu VARCHAR(5))
returns float 
as
begin
	declare @valor float;
	--declare @id_apu VARCHAR(5);

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			/*select sum(p.valor) 
			from t_apu_materiales am
				LEFT JOIN t_productos p ON am.id_productos = p.id
				LEFT JOIN t_apu a ON am.id_apu = a.ID
			where
				am.id_apu = @id_apu*/
			select
				sum(dbo.calcularValorMaterial(@id_apu,p.id))
			from t_apu_equipo ae
				LEFT JOIN t_producto p ON ae.id_producto = p.id
				LEFT JOIN t_apu a ON ae.id_apu = a.ID
			where 
				a.codigo = @id_apu
		);
	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalMaterial('0001') as 'total_materiales';