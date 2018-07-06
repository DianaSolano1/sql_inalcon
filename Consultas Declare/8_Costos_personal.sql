		----------------------------------------------------------------------------------------------------
		DECLARE @T_COSTOS_PERSONAL TABLE 
		(
			rol								VARCHAR (100)	NOT NULL,
			cargo							VARCHAR (100)	NOT NULL,
			cantidad						INT				NOT NULL,
			experiencia_general_específica	VARCHAR (100)	NOT NULL,
			dedicacion						NUMERIC (6, 3)	NOT NULL,
			tiempo_ejecucion				INT				NOT NULL,
			sueldo_basico					NUMERIC (18, 1)	NOT NULL,
			costo_parcial					NUMERIC (18, 1)	NOT NULL
		)

		INSERT @T_COSTOS_PERSONAL (
				rol,
				cargo,
				cantidad,
				experiencia_general_específica,
				dedicacion,
				tiempo_ejecucion,
				sueldo_basico,
				costo_parcial
			)
		SELECT	rc.nombre AS 'rol',
				cs.nombre AS 'cargo',
				cp.cantidad,
				ex.nombre AS 'experiencia_general_específica',
				cp.dedicacion,
				cp.tiempo_ejecucion,
				cs.sueldo_basico,
				dbo.CostoPersonalParcial(cs.ID) AS 'costo_parcial'
		FROM t_costos_personal cp
				LEFT JOIN t_experiencia ex ON cp.id_experiencia = ex.ID
				LEFT JOIN t_cargo_sueldo cs ON cp.id_experiencia = cs.ID
				LEFT JOIN t_rol_cargo rc ON cs.id_rol = rc.ID
		ORDER BY rc.nombre 

		SELECT * FROM @T_COSTOS_PERSONAL


		----------------------------------------------------------------------------------------------------

		DECLARE @T_TOTAL_COSTOS_PERSONAL TABLE 
		(
			sub_total		NUMERIC (18, 2)	NOT NULL,
			FM				NUMERIC (5, 2)	NOT NULL,
			total_personal	NUMERIC (18, 2)	NULL
		)

		INSERT @T_TOTAL_COSTOS_PERSONAL (
				sub_total,
				FM
			)
		SELECT	(dbo.CostoPersonalSubTotal()),
				2

		UPDATE @T_TOTAL_COSTOS_PERSONAL
		SET
			total_personal			= (dbo.TotalPersonal())
		FROM
			@T_TOTAL_COSTOS_PERSONAL ADM
		WHERE
			total_personal	IS NULL

		SELECT * FROM @T_TOTAL_COSTOS_PERSONAL

		----------------------------------------------------------------------------------------------------
		DECLARE @T_OTROS_COSTOS_DIRECTOS TABLE 
		(
			descripcion			VARCHAR (200)	NOT NULL,
			cantidad			INT				NOT NULL,
			unidad				VARCHAR (30)	NOT NULL,
			dedicacion			NUMERIC (6, 3)	NOT NULL,
			tiempo_ejecucion	INT				NOT NULL,
			tarifa				NUMERIC (18, 2)	NOT NULL,
			costo_parcial		NUMERIC (18, 2)	NOT NULL,
			total_costo_parcial	NUMERIC (18, 2)	NOT NULL
		)

		INSERT @T_OTROS_COSTOS_DIRECTOS (
				descripcion,
				cantidad,
				unidad,
				dedicacion,
				tiempo_ejecucion,
				tarifa,
				costo_parcial,
				total_costo_parcial
			)
		SELECT	cd.nombre AS 'descripcion',
				cd.cantidad,
				u.nombre AS 'unidad',
				cd.dedicacion,
				cd.tiempo_ejecucion,
				cd.tarifa,
				dbo.CostoDirectoParcial(cd.id) AS 'costo_parcial',
				dbo.CostoDirectoParcialTotal()
		FROM t_costo_directo cd
				LEFT JOIN t_unidad u ON cd.id_unidad = u.id
		ORDER BY cd.nombre 

		SELECT * FROM @T_OTROS_COSTOS_DIRECTOS

		----------------------------------------------------------------------------------------------------
		DECLARE @T_SUPERVISION_INTERVENTORIA TABLE 
		(
			total_costos_interventoria	NUMERIC (18, 2)	NOT NULL,
			mas_iva						NUMERIC (18, 2)	NOT NULL,
			costo_total					NUMERIC (18, 2)	NOT NULL
		)

		INSERT @T_SUPERVISION_INTERVENTORIA (
				total_costos_interventoria,
				mas_iva,
				costo_total
			)
		SELECT	dbo.TotalCostosInterventoria() AS Total_Costos_Interventoria,
				dbo.TotalCostosMasIva() AS Total_Costos_De_Iva,
				dbo.TotalCostos() AS Total_Costos

		SELECT * FROM @T_SUPERVISION_INTERVENTORIA