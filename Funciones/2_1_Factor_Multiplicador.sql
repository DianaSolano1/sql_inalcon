create function calcularFactorMultiplicador(@item varchar(10))
returns float
as
begin
	
	declare @esItem varchar(2);
	declare @valor float;

	set @esItem = (select top 1 tfb.ID from t_factor_base
						tfb
						where tfb.item = @item)
	
	if @esItem is not null
	begin
		set @valor = (select sum(tfd.porcentaje) FROM t_factor_base tfb
			LEFT JOIN t_factor_subitem tfs ON tfb.ID = tfs.id_factor_base
			LEFT JOIN t_factor_detalle tfd ON tfs.ID = tfd.id_factor_subitem
						where tfb.item = @item);
	end
	else
	begin
		set @valor = (select sum(tfd.porcentaje) from t_factor_subitem tfs
						join t_factor_detalle tfd
						on tfs.ID = tfd.id_factor_subitem
						where tfs.item = @item)
	end
	
	return @valor;
end

go

select dbo.calcularFactorMultiplicador('C') as 'Total';