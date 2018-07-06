create function ValorTotalAPULleno(@codigo_apu VARCHAR(5), @id_apu INT)
returns float 
as
begin
	declare @valor float;

	--set @valor = (select sum(tfd.porcentaje) from t_factor_base tfd );

	IF @valor IS NULL	-- Detecta si tiene algún valor (Para no cambiar nada)
	BEGIN
		SET @valor =   (
				select 
					((dbo.TotalApuInicial(apu.codigo)) * (pg.cantidad))
					--((dbo.TotalApuInicial(apu.codigo)) * (2))
				FROM t_presupuesto_general pg
					LEFT JOIN t_apu apu ON pg.id_APU = apu.ID
				where
					apu.codigo = @codigo_apu
					AND pg.item = @id_apu
			);
	END
	
	IF @valor IS NULL	-- Detecta si aún sigue vacía, después de realizar la función de arriba
	BEGIN
		SET @valor = (
				SELECT
					SUM(dbo.ValorTotalSUBAPULleno(apu.codigo,s.item))
				FROM t_subpresupuesto s
					LEFT JOIN t_apu apu ON s.id_APU = apu.ID
			);
	END 

	return @valor;
end

go

--select * from t_factor_base;

select dbo.ValorTotalAPULleno('0001',1) as 'subtotal_items';