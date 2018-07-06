create function GastosLSTIPorcentajes()
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select SUM(dbo.GastosLPorcentaje(gl.id))
			from t_gasto_legal gl
		);

	return @valor;
end

go

--select * from t_factor_base;

select dbo.GastosLSTIPorcentajes() as 'subtotal_porcentajes';