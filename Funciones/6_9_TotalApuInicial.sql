alter function TotalApuInicial(@id_apu VARCHAR(5))
returns float 
as
begin
	declare @valor float;
	
	set @valor = (
			select (
					dbo.TotalEquipo(a.codigo)				+
					dbo.TotalMaterial(a.codigo)				+
					dbo.TotalTransporteMaterial(a.codigo)	+
					dbo.TotalManoObra(a.codigo)
				)
			from t_apu a
				LEFT JOIN t_apu_equipo ae ON ae.id_apu = a.ID
				LEFT JOIN t_producto p ON ae.id_producto = p.id
			where 
				a.codigo = @id_apu
		);
	return @valor;
end

go

--select * from t_factor_base;

select dbo.TotalApuInicial('0001') as 'total_materiales';