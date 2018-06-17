--select * from t_experiencia;
--select * from t_rol_cargo;
--select * from t_cargo_sueldo;
--select * from t_costos_personal;
--select * from t_costos_directos;

-- Reporte costos personal
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
LEFT JOIN t_rol_cargo rc ON cs.id_rol = rc.ID;

-- Reporte Otros Costos Directos
SELECT	cd.nombre AS 'descripcion',
		cd.cantidad,
		u.nombre AS 'unidad',
		cd.dedicacion,
		cd.tiempo_ejecucion,
		cd.tarifa,
		(cd.tarifa * (cd.dedicacion / 100) * cd.tiempo_ejecucion * cd.cantidad) AS 'costo_parcial'
FROM t_costos_directos cd
LEFT JOIN t_unidades u ON cd.id_unidad = u.id;