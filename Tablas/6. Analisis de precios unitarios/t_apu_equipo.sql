USE prestamos
GO

IF OBJECT_ID ('dbo.t_apu_equipo') IS NOT NULL
	DROP TABLE dbo.t_apu_equipo
GO

CREATE TABLE dbo.t_apu_equipo
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	id_apu			INT NOT NULL,
	id_productos	INT NOT NULL,
	cantidad		NUMERIC (5, 2) NOT NULL,
	rendimiento		NUMERIC (5, 2) NOT NULL,
	CONSTRAINT fk_equipo_apu FOREIGN KEY (id_apu) REFERENCES dbo.t_apu (ID),
	CONSTRAINT fk_equipo_productos FOREIGN KEY (id_productos) REFERENCES dbo.t_productos (ID)
	)
GO