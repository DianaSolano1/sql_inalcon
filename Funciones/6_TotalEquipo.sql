alter function TotalEquipo(@id_apu VARCHAR(5))
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select sum(p.valor) 
			from t_apu_equipo ae
				LEFT JOIN t_productos p ON ae.id_productos = p.id
			where
				ae.id_apu = @id_apu
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalEquipo('001') as 'total_equipo';