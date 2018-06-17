USE prestamos
GO

IF OBJECT_ID ('dbo.t_rol_cargo') IS NOT NULL
	DROP TABLE dbo.t_rol_cargo
GO

CREATE TABLE dbo.t_rol_cargo
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	nombre			VARCHAR (100) NOT NULL
	)
GO