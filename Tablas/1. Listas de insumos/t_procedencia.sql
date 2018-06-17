USE prestamos
GO

IF OBJECT_ID ('dbo.t_procedencia') IS NOT NULL
	DROP TABLE dbo.t_procedencia
GO

CREATE TABLE dbo.t_procedencia
	(
	id			INT IDENTITY PRIMARY KEY NOT NULL,
	nombre		VARCHAR (30) NOT NULL 
	)
GO