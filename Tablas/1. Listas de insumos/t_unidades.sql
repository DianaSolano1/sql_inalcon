USE prestamos
GO

IF OBJECT_ID ('dbo.t_unidades') IS NOT NULL
	DROP TABLE dbo.t_unidades
GO

CREATE TABLE dbo.t_unidades
	(
	id			INT IDENTITY PRIMARY KEY NOT NULL,
	nombre		VARCHAR (30) NOT NULL
	)
GO