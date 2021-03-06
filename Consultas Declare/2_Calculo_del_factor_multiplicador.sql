		DECLARE @T_CALCULO_FM TABLE 
		(
			item_capitulo VARCHAR (5) NOT NULL,
			capitulo VARCHAR (200) NOT NULL,
			porcentaje_capitulo NUMERIC (5, 2) NULL,
			item_subcapitulo VARCHAR (5) NULL,
			subcapitulo VARCHAR (200) NULL,
			porcentaje_subcapitulo NUMERIC (5, 2) NULL,
			item VARCHAR (200) NULL,
			porcentaje_item NUMERIC (5, 2) NULL,
			factor_multiplicador NUMERIC(5, 2) NULL
		)
		INSERT @T_CALCULO_FM (
						item_capitulo, 
						capitulo, 
						porcentaje_capitulo, 
						item_subcapitulo, 
						subcapitulo, 
						porcentaje_subcapitulo, 
						item, 
						porcentaje_item,
						factor_multiplicador)
		SELECT	b.item AS 'item_capitulo',
				b.nombre AS 'capitulo',
				b.porcentaje AS 'porcentaje_capitulo',
				s.item AS 'item_subcapitulo',
				s.nombre AS 'subcapitulo',
				s.porcentaje AS 'porcentaje_subcapitulo',
				d.nombre AS 'item',
				d.porcentaje AS 'porcentaje_item',
				dbo.calcularFactorMultiplicador(b.item) as 'factor_multiplicador'
		FROM t_factor_base b
			LEFT JOIN t_factor_subitem s ON b.ID = s.id_factor_base
			LEFT JOIN t_factor_detalle d ON s.ID = d.id_factor_subitem
		ORDER BY b.item DESC

		UPDATE @T_CALCULO_FM
		SET
			porcentaje_capitulo	= dbo.calcularFactorMultiplicador(item_capitulo)
		FROM
			@T_CALCULO_FM CFM
		WHERE
			porcentaje_capitulo	IS NULL

		SELECT * FROM @T_CALCULO_FM