USE prestamos
GO

IF OBJECT_ID ('dbo.t_costo_directo') IS NOT NULL
	DROP TABLE dbo.t_costo_directo
GO

CREATE TABLE dbo.t_costo_directo
	(
	id					INT IDENTITY PRIMARY KEY NOT NULL,
	id_unidad			INT NOT NULL,
	nombre				VARCHAR (200) NOT NULL,
	cantidad			INT NOT NULL,
	dedicacion			NUMERIC (6, 3) NOT NULL,
	tiempo_ejecucion	INT NOT NULL,
	tarifa				NUMERIC (18, 2) NOT NULL,
	CONSTRAINT fk_costos_directos_unidad FOREIGN KEY (id_unidad) REFERENCES dbo.t_unidades (ID)
	)
GO