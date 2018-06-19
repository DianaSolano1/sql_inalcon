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
				(cp.cantidad * (cp.dedicacion / 100) * cp.tiempo_ejecucion * cs.sueldo_basico) AS 'costo_parcial'
		FROM t_costos_personal cp
				LEFT JOIN t_experiencia ex ON cp.id_experiencia = ex.ID
				LEFT JOIN t_cargo_sueldo cs ON cp.id_experiencia = cs.ID
				LEFT JOIN t_rol_cargo rc ON cs.id_rol = rc.ID
		GROUP BY
			rc.nombre			,
			cs.nombre			,
			cp.cantidad			,
			ex.nombre			,
			cp.dedicacion		,
			cp.tiempo_ejecucion	,
			cs.sueldo_basico	
		HAVING COUNT(*) >= 1
		ORDER BY rc.nombre DESC

		SELECT * FROM @T_COSTOS_PERSONAL


		----------------------------------------------------------------------------------------------------
		DECLARE @T_OTROS_COSTOS_DIRECTOS TABLE 
		(
			descripcion			VARCHAR (200)	NOT NULL,
			cantidad			INT				NOT NULL,
			unidad				VARCHAR (30)	NOT NULL,
			dedicacion			NUMERIC (6, 3)	NOT NULL,
			tiempo_ejecucion	INT				NOT NULL,
			tarifa				NUMERIC (18, 2)	NOT NULL,
			costo_parcial		NUMERIC (18, 2)	NOT NULL
		)

		INSERT @T_OTROS_COSTOS_DIRECTOS (
				descripcion,
				cantidad,
				unidad,
				dedicacion,
				tiempo_ejecucion,
				tarifa,
				costo_parcial
			)
		SELECT	cd.nombre AS 'descripcion',
				cd.cantidad,
				u.nombre AS 'unidad',
				cd.dedicacion,
				cd.tiempo_ejecucion,
				cd.tarifa,
				(cd.tarifa * (cd.dedicacion / 100) * cd.tiempo_ejecucion * cd.cantidad) AS 'costo_parcial'
		FROM t_costos_directos cd
				LEFT JOIN t_unidades u ON cd.id_unidad = u.id
		GROUP BY
			cd.nombre			,
			cd.cantidad			,
			u.nombre			,
			cd.dedicacion		,
			cd.tiempo_ejecucion	,
			cd.tarifa			
		HAVING COUNT(*) >= 1
		ORDER BY cd.nombre DESC

		SELECT * FROM @T_OTROS_COSTOS_DIRECTOS