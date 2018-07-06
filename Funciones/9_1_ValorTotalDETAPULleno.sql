create function ValorTotalDETAPULleno(@codigo_apu VARCHAR(5), @id_detapu INT)
returns float 
as
begin
	declare @valor float;

	IF @valor IS NULL	-- Detecta si tiene algún valor (Para no cambiar nada)
	BEGIN
		SET @valor =   (
				select 
					((dbo.TotalApuInicial(apu.codigo)) * (ds.cantidad))
					--((10) * (ds.cantidad))
				FROM t_detalle_subpresupuesto ds
					LEFT JOIN t_apu apu ON ds.id_APU = apu.ID
				where
					apu.codigo = @codigo_apu
					AND ds.item = @id_detapu
			);
	END
	
	IF @valor IS NULL	-- Detecta si aún sigue vacía, después de realizar la función de arriba
	BEGIN
		SET @valor = 0
	END 

	return @valor;
end

go

--select * from t_factor_base;

select dbo.ValorTotalDETAPULleno('0002',7) as 'subtotal_items';