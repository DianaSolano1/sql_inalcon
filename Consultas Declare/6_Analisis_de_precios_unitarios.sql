		----------------------------------------------------------------------------------------------------
		DECLARE @T_INICIAL_APU TABLE 
		(
			apu					VARCHAR(5)		NOT NULL,
			descripcion			VARCHAR(50)		NOT NULL,
			unidad				VARCHAR (30)	NOT NULL,
			factor_hm			NUMERIC (6, 3)	NOT NULL,
			factor_desperdicio	NUMERIC (6, 3)	NOT NULL,
			costos_directos		NUMERIC (18, 2)	NULL	
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

		--SELECT * FROM @T_INICIAL_APU

		UPDATE @T_INICIAL_APU
		SET
			costos_directos	=	(
				dbo.TotalEquipo(a.codigo)				+
				dbo.TotalMaterial(a.codigo)				+
				dbo.TotalTransporteMaterial(a.codigo)	+
				dbo.TotalManoObra(a.codigo)
			)
		FROM
			@T_INICIAL_APU APU
			LEFT JOIN t_apu a ON a.codigo = apu.apu
			LEFT JOIN t_apu_equipo ae ON ae.id_apu = a.ID
			LEFT JOIN t_productos p ON ae.id_productos = p.id
		WHERE
			costos_directos	IS NULL

		SELECT * FROM @T_INICIAL_APU

		----------------------------------------------------------------------------------------------------
		DECLARE @T_REPORTE_EQUIPO TABLE 
		(
			apu			VARCHAR(5)		NOT NULL,
			equipo		VARCHAR (200)	NOT NULL,
			unidad		VARCHAR (30)	NOT NULL,
			cantidad	NUMERIC (5, 2)	NOT NULL,
			tarifa_dia	NUMERIC (18, 2)	NULL,
			rendimiento	NUMERIC (5, 2)	NOT NULL,
			valor		NUMERIC (18, 2)	NOT NULL,
			total		NUMERIC (18, 2)	NULL
		)

		INSERT @T_REPORTE_EQUIPO (
				apu,
				equipo,
				unidad,
				cantidad,
				tarifa_dia,
				rendimiento,
				valor)
		SELECT	a.codigo AS 'apu',
				p.nombre AS 'equipo',
				u.nombre AS 'unidad',
				ae.cantidad,
				p.valor AS 'tarifa_dia',
				ae.rendimiento,
				(p.valor * ae.rendimiento) AS valor
		FROM t_apu_equipo ae
				LEFT JOIN t_productos p ON ae.id_productos = p.id
				LEFT JOIN t_unidades u ON p.id_unidad = u.id
				LEFT JOIN t_apu a ON ae.id_apu = a.ID
		GROUP BY
			a.codigo		,
			p.nombre		,
			u.nombre		,
			ae.cantidad		,
			p.valor			,
			ae.rendimiento	,
			p.valor
		HAVING COUNT(*) >= 1
		ORDER BY a.codigo DESC

		--SELECT * FROM @T_REPORTE_EQUIPO

		UPDATE @T_REPORTE_EQUIPO
		SET
			total	=	dbo.TotalEquipo(apu)
		FROM
			@T_REPORTE_EQUIPO RE
		WHERE
			total	IS NULL

		SELECT * FROM @T_REPORTE_EQUIPO

		----------------------------------------------------------------------------------------------------
		DECLARE @T_REPORTE_MATERIALES TABLE 
		(
			apu					VARCHAR(5)		NOT NULL,
			materiales			VARCHAR (200)	NOT NULL,
			unidad				VARCHAR (30)	NOT NULL,
			cantidad			NUMERIC (5, 2)	NOT NULL,
			valor_unitario		NUMERIC (18, 2)	NULL,
			factor_desperdicio	NUMERIC (5, 2)	NOT NULL,
			valor				NUMERIC (18, 2)	NULL,
			total				NUMERIC (18, 2)	NULL
		)
		
		INSERT @T_REPORTE_MATERIALES (
				apu,
				materiales,
				unidad,
				cantidad,
				valor_unitario,
				factor_desperdicio)
		SELECT	a.codigo AS 'apu',
				p.nombre AS 'materiales',
				u.nombre AS 'unidad',
				am.cantidad AS 'cantidad',
				p.valor AS 'valor_unitario',
				a.factor_desperdicio
				--(am.cantidad * p.valor * (1 + (a.factor_desperdicio / 100))) AS 'valor'
		FROM t_apu_materiales am
				LEFT JOIN t_productos p ON am.id_productos = p.id
				LEFT JOIN t_unidades u ON p.id_unidad = u.id
				LEFT JOIN t_apu a ON am.id_apu = a.ID
		GROUP BY
			a.codigo			,
			p.nombre			,
			u.nombre			,
			am.cantidad			,
			p.valor				,
			a.factor_desperdicio	
		HAVING COUNT(*) >= 1
		ORDER BY a.codigo DESC

		--SELECT * FROM @T_REPORTE_MATERIALES

		UPDATE @T_REPORTE_MATERIALES
		SET
			valor	=	dbo.calcularValorMaterial(apu,p.id)
		FROM
			@T_REPORTE_MATERIALES RM
			LEFT JOIN t_productos p ON RM.materiales = p.nombre
		--WHERE
			--valor	IS NULL

		--SELECT * FROM @T_REPORTE_MATERIALES

		UPDATE @T_REPORTE_MATERIALES
		SET
			total	=	dbo.TotalMaterial(apu)
		FROM
			@T_REPORTE_MATERIALES RM
			LEFT JOIN t_productos p ON RM.materiales = p.nombre
		WHERE
			total	IS NULL

		SELECT * FROM @T_REPORTE_MATERIALES

		----------------------------------------------------------------------------------------------------
		DECLARE @T_REPORTE_TRANSPORTE_MATERIALES TABLE 
		(
			apu						VARCHAR(5)		NOT NULL,
			transporte_materiales	VARCHAR (200)	NOT NULL,
			vol_peso_cant			VARCHAR (30)	NOT NULL,
			distancia				NUMERIC (10, 2)	NOT NULL,
			m3_km					NUMERIC (18, 2)	NOT NULL,
			tarifa					NUMERIC (10, 2)	NOT NULL,
			valor_unitario			NUMERIC (20, 2)	NOT NULL,
			total					NUMERIC (18, 2)	NULL
		)
		
		INSERT @T_REPORTE_TRANSPORTE_MATERIALES (
				apu,
				transporte_materiales,
				vol_peso_cant,
				distancia,
				m3_km,
				tarifa,
				valor_unitario)
		SELECT	a.codigo AS 'apu',
				p.nombre AS 'transporte_material',
				u.nombre AS 'vol_peso_cant',
				atm.distancia,
				p.valor AS 'm3_km',
				atm.tarifa,
				(p.valor * atm.tarifa) AS 'valor_unitario'
		FROM t_apu_transporte_material atm
				LEFT JOIN t_productos p ON atm.id_productos = p.id
				LEFT JOIN t_unidades u ON p.id_unidad = u.id
				LEFT JOIN t_apu a ON atm.id_apu = a.ID
		GROUP BY
			a.codigo			,
			p.nombre			,
			u.nombre			,
			atm.distancia		,
			p.valor				,
			atm.tarifa				
		HAVING COUNT(*) >= 1
		ORDER BY a.codigo DESC

		--SELECT * FROM @T_REPORTE_TRANSPORTE_MATERIALES

		UPDATE @T_REPORTE_TRANSPORTE_MATERIALES
		SET
			total	=	dbo.TotalTransporteMaterial(apu)
		FROM
			@T_REPORTE_TRANSPORTE_MATERIALES RTM
			--LEFT JOIN t_productos p ON RTM.transporte_materiales = p.nombre
		WHERE
			total	IS NULL

		SELECT * FROM @T_REPORTE_TRANSPORTE_MATERIALES

		----------------------------------------------------------------------------------------------------
		DECLARE @T_REPORTE_MANO_OBRA TABLE 
		(
			apu					VARCHAR(5)		NOT NULL,
			mano_obra			VARCHAR (200)	NULL,
			jornal				NUMERIC (18, 2)	NULL,
			factor_prestacional	NUMERIC (5, 2)	NULL,
			jornal_total		NUMERIC (18, 2)	NULL,
			redimiento			NUMERIC (5, 2)	NOT NULL,
			valor				NUMERIC (18, 2) NULL,
			total				NUMERIC (18, 2)	NULL
		)
		
		INSERT @T_REPORTE_MANO_OBRA (
				apu,
				mano_obra,
				redimiento)
		SELECT	a.codigo AS 'apu',
				cd.descripcion AS 'mano_obra',
				amo.rendimiento
		FROM t_apu_mano_obra amo
				LEFT JOIN t_cuadrilla c ON amo.id_cuadrilla = c.id
				LEFT JOIN t_cuadrilla_detalle cd ON c.id = cd.id_cuadrilla
				LEFT JOIN t_apu a ON amo.id_apu = a.ID
		GROUP BY
			a.codigo		,
			cd.descripcion	,
			amo.rendimiento	
		HAVING COUNT(*) >= 1
		ORDER BY a.codigo DESC

		--SELECT * FROM @T_REPORTE_MANO_OBRA

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			jornal	=	dbo.ManoObraJornal(a.codigo,cdet.id)
		FROM
			@T_REPORTE_MANO_OBRA RMO
			LEFT JOIN t_cuadrilla_detalle cdet ON RMO.mano_obra = cdet.descripcion
			left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
			left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
			left join t_apu a ON a.ID = amo.id_apu
		WHERE
			jornal	IS NULL

		--SELECT * FROM @T_REPORTE_MANO_OBRA

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			factor_prestacional	=	(dbo.calcularFactorMultiplicadorTotal() / 100)
		FROM
			@T_REPORTE_MANO_OBRA RMO
			--LEFT JOIN t_productos p ON RTM.transporte_materiales = p.nombre
		WHERE
			factor_prestacional	IS NULL

		--SELECT * FROM @T_REPORTE_MANO_OBRA

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			jornal_total	=	dbo.ManoObraJornalTotal(a.codigo,cdet.id)
		FROM
			@T_REPORTE_MANO_OBRA RMO
			LEFT JOIN t_cuadrilla_detalle cdet ON RMO.mano_obra = cdet.descripcion
			left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
			left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
			left join t_apu a ON a.ID = amo.id_apu
		WHERE
			jornal_total	IS NULL

		--SELECT * FROM @T_REPORTE_MANO_OBRA

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			valor	=	dbo.ManoObraValor(a.codigo,cdet.id)
		FROM
			@T_REPORTE_MANO_OBRA RMO
			--LEFT JOIN t_productos p ON RTM.transporte_materiales = p.nombre
			LEFT JOIN t_cuadrilla_detalle cdet ON RMO.mano_obra = cdet.descripcion
			left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
			left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
			left join t_apu a ON a.ID = amo.id_apu
		WHERE
			valor	IS NULL

		--SELECT * FROM @T_REPORTE_MANO_OBRA

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			total	=	dbo.TotalManoObra(apu)
		FROM
			@T_REPORTE_MANO_OBRA RMO
		WHERE
			total	IS NULL

		SELECT * FROM @T_REPORTE_MANO_OBRA