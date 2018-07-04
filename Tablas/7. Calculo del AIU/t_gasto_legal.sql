USE prestamos
GO

IF OBJECT_ID ('dbo.t_gasto_legal') IS NOT NULL
	DROP TABLE dbo.t_gasto_legal
GO

CREATE TABLE dbo.t_gasto_legal
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_AIU			INT NOT NULL,
	descripcion		VARCHAR (200) NOT NULL,
	valores			NUMERIC (19, 2) NULL,
	porcentaje		NUMERIC (6, 3) NULL,
	CONSTRAINT fk_gastos_legales_AIU FOREIGN KEY (id_AIU) REFERENCES dbo.t_AIU (ID)
	)
GO