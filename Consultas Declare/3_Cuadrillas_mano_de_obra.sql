		-- Reporte de una sola linea para la cuadrilla
		SELECT	l.valor AS 'salario_minimo',
				c.dias_labor AS 'dias_laborales',
				c.horas_dia,
				dbo.calcularFactorMultiplicadorTotal() as 'factor_prestacional'
		FROM t_cuadrilla c
		LEFT JOIN t_legal l ON c.id_salrio_minimo = l.id;

		-- Reporte primera tabla cuadrilla
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
		LEFT JOIN t_legal cl ON cd.id_salrio_minimo = cl.id;
		
		DECLARE @T_CUADRILLAS TABLE
				(
					id_jornal_empleado		INT				NOT NULL,
					descripcion_cuadrillas	VARCHAR (200)	NOT NULL,
					cantidad_oficial		INT				NOT NULL,
					cantidad_ayudante		INT				NOT NULL,
					valor_jornal			NUMERIC(18,2)	NULL	,
					valor_jornal_prestacion	NUMERIC(18,2)	NULL	,
					cuadrilla_h_prestacion	NUMERIC(18,2)	NULL	
				)

		INSERT @T_CUADRILLAS (
			id_jornal_empleado,
			descripcion_cuadrillas,
			cantidad_oficial,
			cantidad_ayudante,
			valor_jornal)
		SELECT
			cdet.id_jornal_empleado,
			cdet.descripcion AS 'descripcion_cuadrillas',
			cdet.cantidad_oficial,
			cdet.cantidad_ayudante,
			(
				-- para el de oficial
				(cdet.cantidad_oficial * dbo.ObtenerValorJornal(cdet.id_jornal_empleado,  1))

				+
				-- para el de ayudante
				(cdet.cantidad_ayudante * dbo.ObtenerValorJornal(cdet.id_jornal_empleado, 0))

			) as 'valor_jornal_ayudante'

		FROM t_cuadrilla_detalle cdet
			LEFT JOIN t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
		GROUP BY
			cdet.id_jornal_empleado,
			cdet.descripcion,
			cdet.cantidad_oficial,
			cdet.cantidad_ayudante
		HAVING COUNT(*) >= 1
		ORDER BY cdet.descripcion DESC;


		--SELECT * FROM @T_CUADRILLAS

		UPDATE @T_CUADRILLAS
		SET
			valor_jornal_prestacion	=	(valor_jornal * dbo.calcularFactorMultiplicadorTotal())
		FROM
			@T_CUADRILLAS CFM
		WHERE
			valor_jornal_prestacion	IS NULL

		--SELECT * FROM @T_CUADRILLAS

		UPDATE @T_CUADRILLAS
		SET
			cuadrilla_h_prestacion	=	(CFM.valor_jornal_prestacion * c.horas_dia)
		FROM
			@T_CUADRILLAS CFM
			LEFT JOIN t_jornal_empleado je ON CFM.id_jornal_empleado = je.id
			LEFT JOIN t_cuadrilla c ON je.id_cuadrilla = c.id
		WHERE
			cuadrilla_h_prestacion	IS NULL

		SELECT * FROM @T_CUADRILLAS