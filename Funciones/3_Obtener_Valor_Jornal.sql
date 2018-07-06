alter function ObtenerValorJornal(@idJornal int, @cargo bit)
  returns int
as begin
  declare @valor float


  set @valor = (select ((1 + (vje.porcentaje / 100)) * (cl.valor / cd.dias_labor))
                from t_jornal_empleado vje
					LEFT JOIN t_cuadrilla cd ON vje.id_cuadrilla = cd.id
					LEFT JOIN t_legal cl ON cd.id_salario_minimo = cl.id
                where vje.sn_ayudante = @cargo 
					and vje.id = @idJornal)

  if(@valor is null) begin
    set @valor = 0
  end


  return @valor


end

go

select dbo.ObtenerValorJornal(1, 1) as 'valor_jornal';