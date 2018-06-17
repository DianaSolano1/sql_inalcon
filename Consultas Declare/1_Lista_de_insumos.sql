		DECLARE @T_CALCULO_FM TABLE 
		(
			item_capitulo VARCHAR (5) NOT NULL,
			capitulo VARCHAR (200) NOT NULL,
			porcentaje_capitulo INT NULL,
			item_subcapitulo VARCHAR (5) NULL,
			subcapitulo VARCHAR (200) NULL,
			porcentaje_subcapitulo NUMERIC (5, 2) NULL,
			item VARCHAR (200) NOT NULL,
			porcentaje_item NUMERIC (5, 2) NULL
		)
		----------------------------------------------------------------------------------------------------
		-- GUARDA LOS DATOS PARA LA TABLA
		INSERT @T_REPORTE_INSUMOS (descripcion, unidad, antes_iva, aplica_iva, valor_total, procedencia)
		SELECT  p.nombre AS 'descripcion',
				u.nombre AS 'unidad',
				p.valor AS 'antes_iva',
				--@aplica_iva,
				p.sn_iva AS 'aplica_iva',
				--(p.valor * (1 + (l.valor / 100))) AS 'valor_total',
				dbo.fc_detectarIva(p.id)	as 'valor_total',
				--(p.valor * (1 + (l.valor / 100))) AS 'valor_total',
				pc.nombre AS 'procedencia'
		FROM	t_productos p
				LEFT JOIN t_unidades u ON p.id_unidad = u.id
				LEFT JOIN t_procedencia pc ON p.id_procedencia = pc.id
				LEFT JOIN t_legal l ON p.id_iva = l.id
		GROUP BY
			p.id		,
			p.nombre	,
			u.nombre	,
			p.valor		,
			p.sn_iva	,
			l.valor		,
			pc.nombre
		HAVING COUNT(*) >= 1
		ORDER BY p.nombre DESC

		SELECT * FROM @T_REPORTE_INSUMOS

		/*SELECT 
			R.*, 
			dbo.detectarIva(p.id)	as 'valor total' 
		FROM @T_REPORTE_INSUMOS R 
		LEFT JOIN t_productos p ON p.nombre = R.descripcion;*/

		/*DECLARE @aplica_iva BIT = 1
		IF @aplica_iva = 1							--> Verifica si tiene iva
		BEGIN
			DECLARE @valor_total NUMERIC (18, 2)
			SET @valor_total	=	(@T_REPORTE_INSUMOS.antes_iva * (1 + (t_legal.valor / 100)))
		END ELSE
		IF @aplica_iva = 0							--> Verifica si no tiene iva
		BEGIN
			SET @valor_total	=	t_productos.valor
		END ELSE*/