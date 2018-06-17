USE prestamos
GO

IF OBJECT_ID ('dbo.t_experiencia') IS NOT NULL
	DROP TABLE dbo.t_experiencia
GO

CREATE TABLE dbo.t_experiencia
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	nombre			VARCHAR (100) NOT NULL
	)
GO