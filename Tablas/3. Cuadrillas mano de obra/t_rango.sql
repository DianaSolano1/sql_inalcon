USE prestamos
GO

IF OBJECT_ID ('dbo.t_rango') IS NOT NULL
	DROP TABLE dbo.t_rango
GO

CREATE TABLE dbo.t_rango
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	nombre			VARCHAR(30) NOT NULL
	)
GO