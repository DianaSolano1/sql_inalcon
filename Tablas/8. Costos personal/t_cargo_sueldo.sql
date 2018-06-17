USE prestamos
GO

IF OBJECT_ID ('dbo.t_cargo_sueldo') IS NOT NULL
	DROP TABLE dbo.t_cargo_sueldo
GO

CREATE TABLE dbo.t_cargo_sueldo
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	id_rol			INT NOT NULL,
	nombre			VARCHAR (100) NOT NULL,
	sueldo_basico	NUMERIC (18, 2) DEFAULT (0) NOT NULL,
	CONSTRAINT fk_cargo_rol FOREIGN KEY (id_rol) REFERENCES dbo.t_rol_cargo (ID)
	)
GO