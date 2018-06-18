		----------------------------------------------------------------------------------------------------
		DECLARE @T_REPORTE_APU TABLE 
		(
			apu					VARCHAR(5)		NOT NULL,
			descripcion			VARCHAR(50)		NOT NULL,
			unidad				VARCHAR (30)	NOT NULL
		)

		INSERT @T_REPORTE_APU (
				apu,
				descripcion,
				unidad)
		SELECT	a.codigo AS 'apu',
				a.nombre AS 'descripcion',
				u.nombre AS 'unidad'
		FROM t_apu a
				LEFT JOIN t_unidades u ON a.id_unidad = u.id
		GROUP BY
			a.codigo			,
			a.nombre			,
			u.nombre				
		HAVING COUNT(*) >= 1
		ORDER BY a.codigo DESC

		SELECT * FROM @T_REPORTE_APU