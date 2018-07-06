USE atenea;

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_detectar_iva

CREATE FUNCTION fc_detectar_iva(@id_producto BIGINT)
RETURNS BIGINT
AS BEGIN
   
   DECLARE @tieneIva BIT
   DECLARE @valorIva NUMERIC(18, 2)
   DECLARE @precioARetornar NUMERIC(18, 2)
   DECLARE @precioNormal NUMERIC(18, 2)

   SET @precioNormal = (SELECT valor 
						FROM t_producto 
						WHERE id = @id_producto)
   SET @tieneIva = (SELECT sn_iva 
					FROM t_producto 
					WHERE id = @id_producto)
   SET @valorIva = (SELECT (1 + (l.valor / 100)) AS 'valor_total'
					FROM t_producto p
					LEFT JOIN t_legal l ON p.id_iva = l.id
					WHERE p.id = @id_producto)

   IF @tieneIva = 1							--> Si
   BEGIN
       SET @precioARetornar =   @precioNormal * @valorIva
   END
   ELSE
   BEGIN									--> No
       SET @precioARetornar = @precioNormal
   END 

   RETURN @precioARetornar
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_calcular_factor_multiplicador
CREATE FUNCTION fc_calcular_factor_multiplicador(@item varchar(10))
RETURNS FLOAT
AS
BEGIN
	
	DECLARE @esItem varchar(2);
	DECLARE @valor FLOAT;

	SET @esItem = (SELECT TOP 1 tfb.ID FROM t_factor_base
						tfb
						WHERE tfb.item = @item)
	
	IF @esItem is not NULL
	BEGIN
		SET @valor = (SELECT sum(tfd.porcentaje) FROM t_factor_base tfb
			LEFT JOIN t_factor_subitem tfs ON tfb.ID = tfs.id_factor_base
			LEFT JOIN t_factor_detalle tfd ON tfs.ID = tfd.id_factor_subitem
						WHERE tfb.item = @item);
	END
	else
	BEGIN
		SET @valor = (SELECT sum(tfd.porcentaje) FROM t_factor_subitem tfs
						JOIN t_factor_detalle tfd
						ON tfs.ID = tfd.id_factor_subitem
						WHERE tfs.item = @item)
	END
	
	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_calcular_factor_multiplicador_total
CREATE FUNCTION fc_calcular_factor_multiplicador_total()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
		(SELECT sum(tfd.porcentaje) FROM t_factor_base tfd )
		+
		(SELECT dbo.fc_calcular_factor_multiplicador('C'))
	);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_obtener_valor_jornal
CREATE FUNCTION fc_obtener_valor_jornal(@idJornal int, @cargo bit)
  RETURNS int
AS BEGIN

  DECLARE @valor FLOAT

  SET @valor = (SELECT ((1 + (vje.porcentaje / 100)) * (cl.valor / cd.dias_labor))
                FROM t_jornal_empleado vje
					LEFT JOIN t_cuadrilla cd ON vje.id_cuadrilla = cd.id
					LEFT JOIN t_legal cl ON cd.id_salario_minimo = cl.id
                WHERE vje.sn_ayudante = @cargo 
					AND vje.id = @idJornal)

  IF(@valor is NULL) BEGIN
    SET @valor = 0
  END

  RETURN @valor
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_calcular_valor_material
CREATE FUNCTION fc_calcular_valor_material(@id_apu VARCHAR(5),@id_producto INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT (am.cantidad * p.valor * (1 + (a.factor_desperdicio / 100))) 
			FROM t_apu_material am
				LEFT JOIN t_producto p ON am.id_producto = p.id
				LEFT JOIN t_apu a ON am.id_apu = a.ID
			WHERE
				am.id_apu = @id_apu
				AND am.id_producto = p.id
		);
	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_equipo
CREATE FUNCTION fc_total_equipo(@id_apu VARCHAR(5))
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT sum(p.valor) 
			FROM t_apu_equipo ae
				LEFT JOIN t_producto p ON ae.id_producto = p.id
			WHERE
				ae.id_apu = @id_apu
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_mano_obra_jornal
CREATE FUNCTION fc_mano_obra_jornal(@id_apu VARCHAR(5), @id_cuadrilla INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT (
				-- para el de oficial
				(cdet.cantidad_oficial * dbo.fc_obtener_valor_jornal(cdet.id_jornal_empleado,  1))

				+
				-- para el de ayudante
				(cdet.cantidad_ayudante * dbo.fc_obtener_valor_jornal(cdet.id_jornal_empleado, 0))
			)
			FROM t_cuadrilla_detalle cdet
				LEFT JOIN t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
				LEFT JOIN t_cuadrilla c ON c.id = cdet.id_cuadrilla
				LEFT JOIN t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
				LEFT JOIN t_apu a ON a.ID = amo.id_apu
			WHERE
				a.codigo = @id_apu
				AND cdet.id = @id_cuadrilla
			GROUP BY
				cdet.cantidad_ayudante,
				cdet.cantidad_oficial,
				cdet.id_jornal_empleado
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_mano_obra_jornal_total
CREATE FUNCTION fc_mano_obra_jornal_total(@id_apu VARCHAR(5), @id_cuadrilla INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT ( dbo.fc_mano_obra_jornal(a.codigo,cdet.id) * (dbo.fc_calcular_factor_multiplicador_total() / 100))
			FROM t_cuadrilla_detalle cdet
				LEFT JOIN t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
				LEFT JOIN t_cuadrilla c ON c.id = cdet.id_cuadrilla
				LEFT JOIN t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
				LEFT JOIN t_apu a ON a.ID = amo.id_apu
			WHERE
				a.codigo = @id_apu
				AND cdet.id = @id_cuadrilla
			GROUP BY
				a.codigo,
				cdet.id
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_mano_obra_valor
CREATE FUNCTION fc_mano_obra_valor(@id_apu VARCHAR(5), @id_cuadrilla INT, @id_apu_mano_obra INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT ( dbo.fc_mano_obra_jornal_total(a.codigo,cdet.id) / amo.rendimiento)
			FROM t_cuadrilla_detalle cdet
				LEFT JOIN t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
				LEFT JOIN t_cuadrilla c ON c.id = cdet.id_cuadrilla
				LEFT JOIN t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
				LEFT JOIN t_apu a ON a.ID = amo.id_apu
			WHERE
				a.codigo = @id_apu
				AND cdet.id = @id_cuadrilla
				AND amo.ID = @id_apu_mano_obra
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_mano_obra
CREATE FUNCTION fc_total_mano_obra(@apu VARCHAR(5))
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT sum(dbo.fc_mano_obra_valor(a.codigo,cdet.id,amo.ID)) 
			FROM t_cuadrilla_detalle cdet
				LEFT JOIN t_cuadrilla c ON c.id = cdet.id_cuadrilla
				LEFT JOIN t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
				LEFT JOIN t_apu a ON a.ID = amo.id_apu
			WHERE
				a.codigo = @apu
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_transporte_material
CREATE FUNCTION fc_total_transporte_material(@id_apu VARCHAR(5))
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT sum((p.valor * atm.tarifa)) 
			FROM t_apu_transporte_material atm
				LEFT JOIN t_producto p ON atm.id_producto = p.id
				LEFT JOIN t_apu a ON atm.id_apu = a.ID
			WHERE
				atm.id_apu = @id_apu
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_material
CREATE FUNCTION fc_total_material(@id_apu VARCHAR(5))
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;
	
	SET @valor = (
			SELECT
				sum(dbo.fc_calcular_valor_material(@id_apu,p.id))
			FROM t_apu_equipo ae
				LEFT JOIN t_producto p ON ae.id_producto = p.id
				LEFT JOIN t_apu a ON ae.id_apu = a.ID
			WHERE 
				a.codigo = @id_apu
		);
	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_apu_inicial
CREATE FUNCTION fc_total_apu_inicial(@id_apu VARCHAR(5))
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;
	
	SET @valor = (
			SELECT (
					dbo.fc_total_equipo(a.codigo)				+
					dbo.fc_total_material(a.codigo)				+
					dbo.fc_total_transporte_material(a.codigo)	+
					dbo.fc_total_mano_obra(a.codigo)
				)
			FROM t_apu a
				LEFT JOIN t_apu_equipo ae ON ae.id_apu = a.ID
				LEFT JOIN t_producto p ON ae.id_producto = p.id
			WHERE 
				a.codigo = @id_apu
		);
	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_gastos_campo
CREATE FUNCTION fc_total_gastos_campo(@id INT)
	RETURNS int
AS BEGIN
	DECLARE @valor FLOAT

	SET @valor = (
				SELECT 
					(co.valor * (co.dedicacion / 100) * co.tiempo_obra)
				FROM t_gasto_campo_oficina co
					LEFT JOIN t_AIU aiu ON co.id_AIU = aiu.id
					LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
				WHERE
					co.id = @id
			);

	RETURN @valor

END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_gastos_CO
CREATE FUNCTION fc_total_gastos_CO(@id INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT (co.valor * (co.dedicacion / 100) * co.tiempo_obra)
			FROM t_gasto_campo_oficina co
			WHERE co.id = @id
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_porcentaje_gastos_CO
CREATE FUNCTION fc_porcentaje_gastos_CO(@id INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT (((co.valor * (co.dedicacion / 100) * co.tiempo_obra) / c.valor_contrato) * 100)
			FROM t_gasto_campo_oficina co
				LEFT JOIN t_AIU aiu ON co.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
			WHERE co.id = @id
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_gastos_COSTI_valor
CREATE FUNCTION fc_gastos_COSTI_valor()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT SUM(dbo.fc_total_gastos_CO(co.id))
			FROM t_gasto_campo_oficina co
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_gastos_l_porcentaje
CREATE FUNCTION fc_gastos_l_porcentaje(@id INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT ((gl.valores / cl.valor_contrato) * 100)
			FROM t_gasto_legal gl
				LEFT JOIN t_AIU a ON gl.id_AIU = a.id
				LEFT JOIN t_cliente cl ON a.id_cliente = cl.ID
			WHERE gl.id = @id
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_gastos_LSTI_valores
CREATE FUNCTION fc_gastos_LSTI_valores()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT SUM(gl.valores)
			FROM t_gasto_legal gl
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_gastos_LSTI_porcentaje
CREATE FUNCTION fc_gastos_LSTI_porcentaje()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT SUM(dbo.fc_gastos_l_porcentaje(gl.id))
			FROM t_gasto_legal gl
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_gastos_P_total
CREATE FUNCTION fc_gastos_P_total(@id INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT (gp.cantidad_empleado * gp.factor_prestacional * gp.valor * (gp.dedicacion / 100) * gp.tiempo_obra)
			FROM t_gasto_personal gp
			WHERE gp.id = @id
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_gastos_P_porcentaje
CREATE FUNCTION fc_gastos_P_porcentaje(@id INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT ((dbo.fc_gastos_P_total(gp.id) / c.valor_contrato) * 100 )
			FROM t_gasto_personal gp
				LEFT JOIN t_cargo_sueldo cs ON gp.id_empleado = cs.id
				LEFT JOIN t_AIU aiu ON gp.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
			WHERE gp.id = @id
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_gastos_PSTI
CREATE FUNCTION fc_gastos_PSTI()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT SUM(dbo.fc_gastos_P_total(gp.id))
			FROM t_gasto_personal gp
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_gastos_P_total_porcentaje
CREATE FUNCTION fc_gastos_P_total_porcentaje()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT SUM(dbo.fc_gastos_P_porcentaje(gp.id))
			FROM t_gasto_personal gp
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_impuestos_STI
CREATE FUNCTION fc_impuestos_STI()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT SUM(((i.porcentaje / 100) * c.valor_contrato))
			FROM t_impuesto i
				LEFT JOIN t_AIU aiu ON i.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_impuestos_total_porcentajes
CREATE FUNCTION fc_impuestos_total_porcentajes()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT SUM(i.porcentaje)
			FROM t_impuesto i
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_gastos_COSTI_porcentaje
CREATE FUNCTION fc_gastos_COSTI_porcentaje()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT SUM(dbo.fc_porcentaje_gastos_CO(co.id))
			FROM t_gasto_campo_oficina co
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_porcentaje_admin
CREATE FUNCTION fc_porcentaje_admin()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT 
				dbo.fc_gastos_COSTI_porcentaje() +
				dbo.fc_gastos_LSTI_porcentaje() +
				dbo.fc_gastos_P_total_porcentaje() +
				dbo.fc_impuestos_total_porcentajes()
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_valor_admin

CREATE FUNCTION fc_valor_admin()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT 
				dbo.fc_gastos_COSTI_valor() +
				dbo.fc_gastos_LSTI_valores() +
				dbo.fc_gastos_PSTI() +
				dbo.fc_impuestos_STI()
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_AIU_valor
CREATE FUNCTION fc_total_AIU_valor()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT (SUM(c.valor_contrato * (ai.porcentaje / 100)) + dbo.fc_valor_admin())
			FROM t_admin_imprevisto ai
				LEFT JOIN t_AIU aiu ON ai.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_AIU_porcentaje
CREATE FUNCTION fc_total_AIU_porcentaje()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT (SUM(ai.porcentaje) + dbo.fc_porcentaje_admin())
			FROM t_admin_imprevisto ai
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_costo_personal_parcial
CREATE FUNCTION fc_costo_personal_parcial(@id_cargo INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT 
				(cp.cantidad * (cp.dedicacion / 100) * cp.tiempo_ejecucion * cs.sueldo_basico)
			FROM t_costo_personal cp
				LEFT JOIN t_experiencia ex ON cp.id_experiencia = ex.ID
				LEFT JOIN t_cargo_sueldo cs ON cp.id_experiencia = cs.ID
			WHERE id_cargo = @id_cargo
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_costo_personal_subtotal
CREATE FUNCTION fc_costo_personal_subtotal()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT 
				SUM(dbo.fc_costo_personal_parcial(cs.ID))
			FROM t_cargo_sueldo cs
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_costo_directo_parcial
CREATE FUNCTION fc_costo_directo_parcial(@id INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT 
				(cd.tarifa * (cd.dedicacion / 100) * cd.tiempo_ejecucion * cd.cantidad)
			FROM t_costo_directo cd
			WHERE cd.id = @id
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_costo_directo_parcial_total
CREATE FUNCTION fc_costo_directo_parcial_total()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT 
				SUM(dbo.fc_costo_directo_parcial(cd.id))
			FROM t_costo_directo cd
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_personal
CREATE FUNCTION fc_total_personal()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT 
				((dbo.fc_costo_personal_subtotal()) * 2)
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_costos_interventoria
CREATE FUNCTION fc_total_costos_interventoria()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT 
				(dbo.fc_costo_directo_parcial_total() + dbo.fc_total_personal())
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_costos_mas_iva
CREATE FUNCTION fc_total_costos_mas_iva()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT 
				(dbo.fc_total_costos_interventoria() * (l.valor / 100))
			FROM t_legal l
			WHERE
				l.nombre = 'Iva'
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_total_costos

CREATE FUNCTION fc_total_costos()
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	SET @valor = (
			SELECT 
				(dbo.fc_total_costos_interventoria() + dbo.fc_total_costos_mas_iva())
		);

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_valor_total_DETAPU_lleno
CREATE FUNCTION fc_valor_total_DETAPU_lleno(@codigo_apu VARCHAR(5), @id_detapu INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	IF @valor IS NULL	-- Detecta si tiene algún valor (Para no cambiar nada)
	BEGIN
		SET @valor =   (
				SELECT 
					((dbo.fc_total_apu_inicial(apu.codigo)) * (ds.cantidad))
				FROM t_detalle_subpresupuesto ds
					LEFT JOIN t_apu apu ON ds.id_APU = apu.ID
				WHERE
					apu.codigo = @codigo_apu
					AND ds.item = @id_detapu
			);
	END
	
	IF @valor IS NULL	-- Detecta si aún sigue vacía, después de realizar la función de arriba
	BEGIN
		SET @valor = 0
	END 

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_valor_total_SUBAPU_lleno
CREATE FUNCTION fc_valor_total_SUBAPU_lleno(@codigo_apu VARCHAR(5), @id_subapu INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	IF @valor IS NULL	-- Detecta si tiene algún valor (Para no cambiar nada)
	BEGIN
		SET @valor =   (
				SELECT 
					((dbo.fc_total_apu_inicial(apu.codigo)) * (s.cantidad))
				FROM t_subpresupuesto s
					LEFT JOIN t_apu apu ON s.id_APU = apu.ID
				WHERE
					apu.codigo = @codigo_apu
					AND s.item = @id_subapu
			);
	END
	
	IF @valor IS NULL	-- Detecta si aún sigue vacía, después de realizar la función de arriba
	BEGIN
		SET @valor = (
				SELECT
					SUM(dbo.fc_valor_total_DETAPU_lleno(apu.codigo,ds.item))
				FROM t_detalle_subpresupuesto ds
					LEFT JOIN t_apu apu ON ds.id_APU = apu.ID
				);
	END 

	RETURN @valor;
END

GO

------------------------------------------------------------------------------------------------------------------------------------------------------
-- fc_valor_total_APU_lleno
CREATE FUNCTION fc_valor_total_APU_lleno(@codigo_apu VARCHAR(5), @id_apu INT)
RETURNS FLOAT 
AS
BEGIN
	DECLARE @valor FLOAT;

	IF @valor IS NULL	-- Detecta si tiene algún valor (Para no cambiar nada)
	BEGIN
		SET @valor =   (
				SELECT 
					((dbo.fc_total_apu_inicial(apu.codigo)) * (pg.cantidad))
					--((dbo.TotalApuInicial(apu.codigo)) * (2))
				FROM t_presupuesto_general pg
					LEFT JOIN t_apu apu ON pg.id_APU = apu.ID
				WHERE
					apu.codigo = @codigo_apu
					AND pg.item = @id_apu
			);
	END
	
	IF @valor IS NULL	-- Detecta si aún sigue vacía, después de realizar la función de arriba
	BEGIN
		SET @valor = (
				SELECT
					SUM(dbo.fc_valor_total_SUBAPU_lleno(apu.codigo,s.item))
				FROM t_subpresupuesto s
					LEFT JOIN t_apu apu ON s.id_APU = apu.ID
			);
	END 

	RETURN @valor;
END

GO