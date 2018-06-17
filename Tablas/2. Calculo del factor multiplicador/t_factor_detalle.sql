USE prestamos
GO

IF OBJECT_ID ('dbo.t_factor_detalle') IS NOT NULL
	DROP TABLE dbo.t_factor_detalle
GO

CREATE TABLE dbo.t_factor_detalle
	(
	ID					INT IDENTITY PRIMARY KEY NOT NULL,
	id_factor_subitem	INT NOT NULL,
	nombre				VARCHAR (200) NOT NULL,
	porcentaje			NUMERIC (5, 2) NULL, 
	CONSTRAINT fk_factor_subitem_subitem FOREIGN KEY (id_factor_subitem) REFERENCES dbo.t_factor_subitem (ID)
	)
GO