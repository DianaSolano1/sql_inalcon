		----------------------------------------------------------------------------------------------------
		DECLARE @T_REPORTE_APU TABLE 
		(
			apu			VARCHAR(5)		NOT NULL,
			descripcion	VARCHAR(50)		NOT NULL,
			unidad		VARCHAR (30)	NOT NULL,
			valor_total	NUMERIC (18, 2)	NULL	
		)

		INSERT @T_REPORTE_APU (
				apu,
				descripcion,
				unidad,
				valor_total)
		SELECT	a.codigo AS 'apu',
				a.nombre AS 'descripcion',
				u.nombre AS 'unidad',
				dbo.TotalApuInicial(a.codigo)
		FROM t_apu a
				LEFT JOIN t_unidades u ON a.id_unidad = u.id
		GROUP BY
			a.codigo			,
			a.nombre			,
			u.nombre				
		HAVING COUNT(*) >= 1
		ORDER BY a.codigo DESC

		UPDATE @T_REPORTE_APU
		SET
			valor_total	=	0
		FROM
			@T_REPORTE_APU APU
		WHERE
			valor_total	IS NULL

		SELECT * FROM @T_REPORTE_APU