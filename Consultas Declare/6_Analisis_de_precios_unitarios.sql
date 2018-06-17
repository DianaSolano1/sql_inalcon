		----------------------------------------------------------------------------------------------------
		-- CREA TABLA PRINCIPAL PARA CUADRILLA
		DECLARE @T_INICIAL_APU TABLE 
		(
			apu					VARCHAR(5)		NOT NULL,
			descripcion			VARCHAR(50)		NOT NULL,
			unidad				VARCHAR (30)	NOT NULL,
			factor_hm			NUMERIC (6, 3)	NOT NULL,
			factor_desperdicio	NUMERIC (6, 3)	NOT NULL
		)
		INSERT @T_INICIAL_APU (
				apu,
				descripcion,
				unidad,
				factor_hm,
				factor_desperdicio)
		SELECT	a.codigo AS 'apu',
				a.nombre AS 'descripcion',
				u.nombre AS 'unidad',
				a.factor_hm,
				a.factor_desperdicio
		FROM t_apu a
				LEFT JOIN t_unidades u ON a.id_unidad = u.id
		GROUP BY
			a.codigo			,
			a.nombre			,
			u.nombre			,
			a.factor_hm			,
			a.factor_desperdicio	
		HAVING COUNT(*) >= 1
		ORDER BY a.codigo DESC

		SELECT * FROM @T_INICIAL_APU


		----------------------------------------------------------------------------------------------------
		-- TABLA JORNAL EMPLEADO (OFICIAL, AYUDANTE)
		DECLARE @T_REPORTE_EQUIPO TABLE 
		(
			apu			VARCHAR(5)		NOT NULL,
			equipo		VARCHAR (200)	NOT NULL,
			unidad		VARCHAR (30)	NOT NULL,
			cantidad	NUMERIC (5, 2)	NOT NULL,
			tarifa_dia	NUMERIC (18, 2)	NULL,
			rendimiento	NUMERIC (5, 2)	NOT NULL
		)

		INSERT @T_REPORTE_EQUIPO (
				descripcion,
				porcentaje,
				salario_minimo,
				dias_laborales,
				valor_jornal,
				cargo)
		SELECT	je.descripcion,
				je.porcentaje,
				cl.valor AS 'salario_minimo',
				cd.dias_labor AS 'dias_laborales',
				((1 + (je.porcentaje / 100)) * (cl.valor / cd.dias_labor)) AS 'valor_jornal',
				--(1 + (je.porcentaje / 100)) AS 'porcentaje+1',
				--(cl.valor / cd.dias_labor) AS 'salario/dias',
				je.sn_ayudante AS 'cargo'
		FROM t_jornal_empleado je
				LEFT JOIN t_cuadrilla cd ON je.id_cuadrilla = cd.id
				LEFT JOIN t_legal cl ON cd.id_salario_minimo = cl.id
		GROUP BY
			je.descripcion	,
			je.porcentaje	,
			cl.valor		,
			cd.dias_labor	,
			je.sn_ayudante
		HAVING COUNT(*) >= 1
		ORDER BY je.descripcion DESC

		SELECT * FROM @T_REPORTE_EQUIPO


		----------------------------------------------------------------------------------------------------
		-- DESCRIPCION CUADRILLA
		DECLARE @T_CUADRILLAS TABLE 
		(
			id_jornal_empleado		INT				NOT NULL,
			descripcion_cuadrillas	VARCHAR (200)	NOT NULL,
			cantidad_oficial		INT				NOT NULL,
			cantidad_ayudante		INT				NOT NULL
		)
		
		INSERT @T_CUADRILLAS (
				id_jornal_empleado		,
				descripcion_cuadrillas	,
				cantidad_oficial		,
				cantidad_ayudante)
		SELECT	cdet.id_jornal_empleado,
				cdet.descripcion AS 'descripcion_cuadrillas',
				cdet.cantidad_oficial,
				cdet.cantidad_ayudante
		FROM t_cuadrilla_detalle cdet
				LEFT JOIN t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
		GROUP BY
			cdet.id_jornal_empleado	,
			cdet.descripcion		,
			cdet.cantidad_oficial	,
			cdet.cantidad_ayudante
		HAVING COUNT(*) >= 1
		ORDER BY cdet.descripcion DESC

		SELECT * FROM @T_CUADRILLAS