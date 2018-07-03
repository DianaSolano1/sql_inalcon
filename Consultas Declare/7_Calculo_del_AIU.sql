		----------------------------------------------------------------------------------------------------
		DECLARE @T_VALOR_DIRECTO TABLE 
		(
			valor_directo_proyecto	NUMERIC (18, 2) DEFAULT (0) NOT NULL
		)

		INSERT @T_VALOR_DIRECTO (valor_directo_proyecto)
		SELECT	c.valor_contrato AS 'valor_directo_proyecto'
		FROM t_AIU a
				LEFT JOIN t_cliente c ON a.id_cliente = c.ID
		GROUP BY
			c.valor_contrato
		HAVING COUNT(*) >= 1
		ORDER BY c.valor_contrato DESC

		--SELECT * FROM @T_VALOR_DIRECTO


		----------------------------------------------------------------------------------------------------
		DECLARE @T_GASTOS_CAMPO_OFICINA TABLE 
		(
			id						INT				NOT NULL,
			gastos_campo_oficinas	VARCHAR (200)	NOT NULL,
			valor					NUMERIC (19, 3)	NOT NULL,
			dedicacion				NUMERIC (5, 2)	NOT NULL,
			tiempo_obra				NUMERIC (5, 2)	NOT NULL,
			total					NUMERIC (18, 2)	NOT NULL,
			porcentaje				NUMERIC (6, 3)	NOT NULL,
			subtotal_valor			NUMERIC (18, 2)	NOT NULL,
			GastosCOSTIPorcentaje	NUMERIC (6, 3)	NOT NULL
		)

		INSERT @T_GASTOS_CAMPO_OFICINA (
				id,
				gastos_campo_oficinas,
				valor,
				dedicacion,
				tiempo_obra,
				total,
				porcentaje,
				subtotal_valor,
				GastosCOSTIPorcentaje
			)
		SELECT	co.id,
				co.descripcion AS 'gastos_campo_oficinas',
				co.valor,
				co.dedicacion,
				co.tiempo_obra,
				dbo.TotalGastosCO(co.id) AS 'total',
				dbo.PorcentajeGastosCO(co.id) AS 'porcentaje',
				dbo.GastosCOSTIValor() AS 'GastosCOSTIValor',
				dbo.GastosCOSTIPorcentaje() AS 'GastosCOSTIPorcentaje'
		FROM t_gastos_campos_oficinas co
				LEFT JOIN t_AIU aiu ON co.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		GROUP BY
			co.id			,
			co.descripcion	,
			co.valor		,
			co.dedicacion	,
			co.tiempo_obra	,
			c.valor_contrato
		HAVING COUNT(*) >= 1
		ORDER BY co.id DESC

		SELECT * FROM @T_GASTOS_CAMPO_OFICINA


		----------------------------------------------------------------------------------------------------
		DECLARE @T_GASTOS_LEGALES TABLE 
		(
			id					INT				NOT NULL,
			gastos_legales		VARCHAR (200)	NOT NULL,
			valores				NUMERIC (18, 2)	NOT NULL,
			porcentaje			NUMERIC (6, 3)	NOT NULL,
			subtotal_valor		NUMERIC (18, 2)	NOT NULL,
			GastosLSTIPorcentajes	NUMERIC (6, 3)	NOT NULL
		)

		INSERT @T_GASTOS_LEGALES (
				id,
				gastos_legales,
				valores,
				porcentaje,
				subtotal_valor,
				GastosLSTIPorcentajes
			)
		SELECT	gl.id,
				gl.descripcion AS 'gastos_legales',
				gl.valores,
				dbo.GastosLPorcentaje(gl.id) AS 'porcentaje',
				dbo.GastosLSTIValores() as 'GastosLSTIValores',
				dbo.GastosLSTIPorcentajes() as 'GastosLSTIPorcentajes'
		FROM t_gastos_legales gl
				LEFT JOIN t_AIU a ON gl.id_AIU = a.id
				LEFT JOIN t_cliente cl ON a.id_cliente = cl.ID
		GROUP BY
			gl.id				,
			gl.descripcion		,
			gl.valores			,
			cl.valor_contrato
		HAVING COUNT(*) >= 1
		ORDER BY gl.id DESC

		SELECT * FROM @T_GASTOS_LEGALES


		----------------------------------------------------------------------------------------------------
		DECLARE @T_GASTOS_PERSONAL TABLE 
		(
			id					INT				NOT NULL,
			gastos_personal		VARCHAR (100)	NOT NULL,
			cantidad			INT				NOT NULL,
			factor_prestacional	NUMERIC (5, 2)	NOT NULL,
			valor				NUMERIC (20, 2)	NOT NULL,
			dedicacion			NUMERIC (6, 3)	NOT NULL,
			tiempo_obra			NUMERIC (5, 2)	NOT NULL,
			total				NUMERIC (20, 1)	NOT NULL,
			porcentaje			NUMERIC (5, 2)	NOT NULL,
			subtotal_items		NUMERIC (20, 1)	NOT NULL,
			GastosPTotalPorcentaje	NUMERIC (5, 2)	NOT NULL
		)

		INSERT @T_GASTOS_PERSONAL (
				id,
				gastos_personal,
				cantidad,
				factor_prestacional,
				valor,
				dedicacion,
				tiempo_obra,
				total,
				porcentaje,
				subtotal_items,
				GastosPTotalPorcentaje
			)
		SELECT	gp.id,
				cs.nombre AS 'gastos_personal',
				gp.cantidad_empleado AS 'cantidad',
				gp.factor_prestacional,
				gp.valor,
				gp.dedicacion,
				gp.tiempo_obra,
				dbo.GastosPTotal(gp.id) AS 'total',
				dbo.GastosPPorcentaje(gp.id) AS 'porcentaje',
				dbo.GastosPSTI() AS 'GastosPSTI',
				dbo.GastosPTotalPorcentaje() AS 'GastosPTotalPorcentaje'
		FROM t_gastos_personal gp
				LEFT JOIN t_cargo_sueldo cs ON gp.id_empleado = cs.id
				LEFT JOIN t_AIU aiu ON gp.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		GROUP BY
			gp.id					,
			cs.nombre				,
			gp.cantidad_empleado	,
			gp.factor_prestacional	,
			gp.valor				,
			gp.dedicacion			,
			gp.tiempo_obra			,
			c.valor_contrato		
		HAVING COUNT(*) >= 1
		ORDER BY gp.id DESC

		SELECT * FROM @T_GASTOS_PERSONAL


		----------------------------------------------------------------------------------------------------
		DECLARE @T_IMPUESTOS TABLE 
		(
			id					INT				NOT NULL,
			impuestos			VARCHAR (200)	NOT NULL,
			valores				NUMERIC (18, 2)	NOT NULL,
			porcentaje			NUMERIC (6, 3)	NOT NULL,
			subtotal_items		NUMERIC (18, 2)	NOT NULL,
			ImpuestosTotalPorcentajes	NUMERIC (6, 3)	NOT NULL
		)

		INSERT @T_IMPUESTOS (
				id,
				impuestos,
				valores,
				porcentaje,
				subtotal_items,
				ImpuestosTotalPorcentajes
			)
		SELECT	i.id,
				i.descripcion AS 'impuestos',
				((i.porcentaje / 100) * c.valor_contrato) AS 'valores',
				i.porcentaje AS 'porcentaje',
				dbo.ImpuestosSTI() AS 'ImpuestosSTI',
				dbo.ImpuestosTotalPorcentajes() AS 'ImpuestosTotalPorcentajes'
		FROM t_impuestos i
				LEFT JOIN t_AIU aiu ON i.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		GROUP BY
			i.id			,
			i.descripcion	,
			i.porcentaje	,
			c.valor_contrato
		HAVING COUNT(*) >= 1
		ORDER BY i.id DESC

		SELECT * FROM @T_IMPUESTOS

		----------------------------------------------------------------------------------------------------
		DECLARE @T_ADMIN_IMPREVISTOS_UTIL TABLE 
		(
			id								INT				NOT NULL,
			admision_imprevistos_utilidades	VARCHAR (200)	NOT NULL,
			valores							NUMERIC (18, 2)	NULL,
			porcentaje						NUMERIC (6, 3)	NULL,
			valor_total						NUMERIC(18, 2)	NULL,
			porcentaje_total				NUMERIC(5, 2)	NULL
		)

		INSERT @T_ADMIN_IMPREVISTOS_UTIL (
				id,
				admision_imprevistos_utilidades,
				valores,
				porcentaje
			)
		SELECT	ai.id,
				ai.descripcion AS 'admision_imprevistos_utilidades',
				(c.valor_contrato * (ai.porcentaje / 100)) AS 'valores',
				ai.porcentaje AS 'porcentaje'
		FROM t_admin_imprevistos ai
				LEFT JOIN t_AIU aiu ON ai.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		GROUP BY
			ai.id				,
			ai.descripcion		,
			c.valor_contrato	,
			ai.porcentaje			
		HAVING COUNT(*) >= 1
		ORDER BY ai.id DESC

		--SELECT * FROM @T_ADMIN_IMPREVISTOS_UTIL

		UPDATE @T_ADMIN_IMPREVISTOS_UTIL
		SET
			valores	=	(dbo.ValorAdmin())
		FROM
			@T_ADMIN_IMPREVISTOS_UTIL ADM
		WHERE
			valores	IS NULL

		--SELECT * FROM @T_ADMIN_IMPREVISTOS_UTIL

		UPDATE @T_ADMIN_IMPREVISTOS_UTIL
		SET
			porcentaje	=	(dbo.PorcentajeAdmin())
		FROM
			@T_ADMIN_IMPREVISTOS_UTIL ADM
		WHERE
			porcentaje	IS NULL

		--SELECT * FROM @T_ADMIN_IMPREVISTOS_UTIL

		UPDATE @T_ADMIN_IMPREVISTOS_UTIL
		SET
			valor_total			= (dbo.TotalAIUValor())
		FROM
			@T_ADMIN_IMPREVISTOS_UTIL ADM
		WHERE
			valor_total	IS NULL

		--SELECT * FROM @T_ADMIN_IMPREVISTOS_UTIL

		UPDATE @T_ADMIN_IMPREVISTOS_UTIL
		SET
			porcentaje_total	= (dbo.TotalAIUPorcentaje())
		FROM
			@T_ADMIN_IMPREVISTOS_UTIL ADM
		WHERE
			porcentaje_total	IS NULL

		SELECT * FROM @T_ADMIN_IMPREVISTOS_UTIL