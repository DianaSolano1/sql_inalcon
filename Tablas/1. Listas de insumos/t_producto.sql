USE prestamos
GO

IF OBJECT_ID ('dbo.t_producto') IS NOT NULL
	DROP TABLE dbo.t_producto
GO

CREATE TABLE dbo.t_producto
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_unidad		INT NOT NULL,
	id_procedencia	INT NOT NULL,
	id_iva			INT NOT NULL,
	nombre			VARCHAR (200) NOT NULL,
	valor			NUMERIC (18, 2) DEFAULT (0) NULL,
	sn_iva			BIT NOT NULL,
	CONSTRAINT fk_productos_unidad FOREIGN KEY (id_unidad) REFERENCES dbo.t_unidades (ID),
	CONSTRAINT fk_productos_procedencia FOREIGN KEY (id_procedencia) REFERENCES dbo.t_procedencia (ID),
	CONSTRAINT fk_productos_legal FOREIGN KEY (id_iva) REFERENCES dbo.t_legal (ID)
	)
GO