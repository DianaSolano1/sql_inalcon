create function ObtenerValorJornal(@idJornal int, @cargo bit)
  returns int
as begin
  declare @valor float


  set @valor = (select vje.valor_jornal
                from v_jornal_empleado vje
                where vje.cargo = @cargo and vje.id = @idJornal)

  if(@valor is null) begin
    set @valor = 0
  end


  return @valor


end