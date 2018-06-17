USE prestamos
GO

IF OBJECT_ID ('dbo.t_factor_base') IS NOT NULL
	DROP TABLE dbo.t_factor_base
GO

CREATE TABLE dbo.t_factor_base
	(
	ID					INT IDENTITY PRIMARY KEY NOT NULL,
	item				VARCHAR (5) NOT NULL,
	nombre				VARCHAR (200) NOT NULL,
	porcentaje			INT NULL
	)
GO