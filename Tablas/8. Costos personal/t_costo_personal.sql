USE prestamos
GO

IF OBJECT_ID ('dbo.t_costo_personal') IS NOT NULL
	DROP TABLE dbo.t_costo_personal
GO

CREATE TABLE dbo.t_costo_personal
	(
	ID					INT IDENTITY PRIMARY KEY NOT NULL,
	id_experiencia		INT NOT NULL,
	id_cargo			INT NOT NULL,
	cantidad			INT NOT NULL,
	dedicacion			NUMERIC (6, 3) NOT NULL,
	tiempo_ejecucion	INT NOT NULL,
	CONSTRAINT fk_costo_personal_experiencia FOREIGN KEY (id_experiencia) REFERENCES dbo.t_experiencia (ID),
	CONSTRAINT fk_costo_personal_cargo FOREIGN KEY (id_cargo) REFERENCES dbo.t_cargo_sueldo (ID)
	)
GO