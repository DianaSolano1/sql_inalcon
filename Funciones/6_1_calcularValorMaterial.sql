create function calcularValorMaterial(@id_apu VARCHAR(5),@id_producto INT)
returns float 
as
begin
	declare @valor float;
	--declare @id_apu VARCHAR(5);

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );
	set @valor = (
			select (am.cantidad * p.valor * (1 + (a.factor_desperdicio / 100))) 
			from t_apu_material am
				LEFT JOIN t_producto p ON am.id_producto = p.id
				LEFT JOIN t_apu a ON am.id_apu = a.ID
			where
				am.id_apu = @id_apu
				AND am.id_producto = p.id
		);
	return @valor;
end

go

--select * from t_factor_base;

select dbo.calcularValorMaterial('001',0) as 'valor';