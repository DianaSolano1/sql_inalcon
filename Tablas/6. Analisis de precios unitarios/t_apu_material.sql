USE prestamos
GO

IF OBJECT_ID ('dbo.t_apu_material') IS NOT NULL
	DROP TABLE dbo.t_apu_material
GO

CREATE TABLE dbo.t_apu_material
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	id_apu			INT NOT NULL,
	id_productos	INT NOT NULL,
	cantidad		NUMERIC (5, 2) NOT NULL,
	CONSTRAINT fk_materiales_apu FOREIGN KEY (id_apu) REFERENCES dbo.t_apu (ID),
	CONSTRAINT fk_materiales_productos FOREIGN KEY (id_productos) REFERENCES dbo.t_productos (ID)
	)
GO