USE prestamos
GO

IF OBJECT_ID ('dbo.t_gasto_campo_oficina') IS NOT NULL
	DROP TABLE dbo.t_gasto_campo_oficina
GO

CREATE TABLE dbo.t_gasto_campo_oficina
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_AIU			INT NOT NULL,
	descripcion		VARCHAR (200) NOT NULL,
	valor			NUMERIC (19, 3) DEFAULT (0) NOT NULL,
	dedicacion		NUMERIC (6, 3) NOT NULL,
	tiempo_obra		NUMERIC (5, 2) NOT NULL,
	CONSTRAINT fk_gastos_campos_oficinas_AIU FOREIGN KEY (id_AIU) REFERENCES dbo.t_AIU (ID)
	)
GO