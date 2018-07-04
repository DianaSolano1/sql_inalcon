USE prestamos
GO

IF OBJECT_ID ('dbo.t_unidad') IS NOT NULL
	DROP TABLE dbo.t_unidad
GO

CREATE TABLE dbo.t_unidad
	(
	id			INT IDENTITY PRIMARY KEY NOT NULL,
	nombre		VARCHAR (30) NOT NULL
	)
GO