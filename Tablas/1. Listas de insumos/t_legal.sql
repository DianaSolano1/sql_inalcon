USE prestamos
GO

IF OBJECT_ID ('dbo.t_legal') IS NOT NULL
	DROP TABLE dbo.t_legal
GO

CREATE TABLE dbo.t_legal
	(
	id			INT IDENTITY PRIMARY KEY NOT NULL,
	nombre		VARCHAR (30) NOT NULL,
	anno		DATE NOT NULL,
	valor		NUMERIC (18, 2) DEFAULT (0) NOT NULL
	)
GO