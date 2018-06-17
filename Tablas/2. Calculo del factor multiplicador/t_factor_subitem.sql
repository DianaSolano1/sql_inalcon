USE prestamos
GO

IF OBJECT_ID ('dbo.t_factor_subitem') IS NOT NULL
	DROP TABLE dbo.t_factor_subitem
GO

CREATE TABLE dbo.t_factor_subitem
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	id_factor_base	INT NOT NULL,
	item			VARCHAR (5) NULL,
	nombre			VARCHAR (200) NULL,
	porcentaje		NUMERIC (5, 2) NULL,
	CONSTRAINT fk_factor_subitem_base FOREIGN KEY (id_factor_base) REFERENCES dbo.t_factor_base (ID)
	)
GO