USE prestamos
GO

IF OBJECT_ID ('dbo.t_impuestos') IS NOT NULL
	DROP TABLE dbo.t_impuestos
GO

CREATE TABLE dbo.t_impuestos
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_AIU			INT NOT NULL,
	descripcion		VARCHAR (200) NOT NULL,
	porcentaje		NUMERIC (6, 3) NOT NULL,
	CONSTRAINT fk_impuestos_AIU FOREIGN KEY (id_AIU) REFERENCES dbo.t_AIU (ID)
	)
GO