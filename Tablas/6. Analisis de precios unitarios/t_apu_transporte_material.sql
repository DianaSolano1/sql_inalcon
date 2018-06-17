USE prestamos
GO

IF OBJECT_ID ('dbo.t_apu_transporte_material') IS NOT NULL
	DROP TABLE dbo.t_apu_transporte_material
GO

CREATE TABLE dbo.t_apu_transporte_material
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	id_apu			INT NOT NULL,
	id_productos	INT NOT NULL,
	distancia		NUMERIC (10, 2) NOT NULL,
	tarifa			NUMERIC (10, 2) DEFAULT (0) NOT NULL,
	CONSTRAINT fk_transporte_material_apu FOREIGN KEY (id_apu) REFERENCES dbo.t_apu (ID),
	CONSTRAINT fk_transporte_material_productos FOREIGN KEY (id_productos) REFERENCES dbo.t_productos (ID)
	)
GO