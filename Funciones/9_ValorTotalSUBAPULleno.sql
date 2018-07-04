alter function ValorTotalSUBAPULleno(@codigo_apu VARCHAR(5), @id_subapu INT)
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );

	IF @valor IS NULL	-- Detecta si tiene algún valor (Para no cambiar nada)
	BEGIN
		SET @valor =   (
				select 
					((dbo.TotalApuInicial(apu.codigo)) * (s.cantidad))
					--((10) * (s.cantidad))
				FROM t_subpresupuesto s
					LEFT JOIN t_apu apu ON s.id_APU = apu.ID
				where
					apu.codigo = @codigo_apu
					AND s.item = @id_subapu
			);
	END
	
	IF @valor IS NULL	-- Detecta si aún sigue vacía, después de realizar la función de arriba
	BEGIN
		SET @valor = (
				SELECT
					SUM(dbo.ValorTotalDETAPULleno(apu.codigo,ds.item))
				FROM t_detalle_subpresupuesto ds
					LEFT JOIN t_apu apu ON ds.id_APU = apu.ID
				);
	END 

	return @valor;
end

go

--select * from t_factor_base;

select dbo.ValorTotalSUBAPULleno('0002',1) as 'subtotal_items';