alter function ManoObraJornalTotal(@id_apu VARCHAR(5), @id_cuadrilla INT)
returns float 
as
begin
	declare @valor float;

	set @valor = (
			select ( dbo.ManoObraJornal(a.codigo,cdet.id) * (dbo.calcularFactorMultiplicadorTotal() / 100))
			from t_cuadrilla_detalle cdet
				left join t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
				left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
				left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
				left join t_apu a ON a.ID = amo.id_apu
			where
				a.codigo = @id_apu
				AND cdet.id = @id_cuadrilla
			group by
				a.codigo,
				cdet.id
		);

	return @valor;
end

go

--select * from t_factor_base;

select	dbo.ManoObraJornal('0001',2) as 'jornal', 
		dbo.calcularFactorMultiplicadorTotal() as 'factor multiplicador',
		(dbo.calcularFactorMultiplicadorTotal() / 100) as 'factor prestacional',
		dbo.ManoObraJornalTotal('0001',2) as 'jornal total';