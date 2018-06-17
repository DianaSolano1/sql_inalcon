USE prestamos
GO

IF OBJECT_ID ('dbo.t_apu_mano_obra') IS NOT NULL
	DROP TABLE dbo.t_apu_mano_obra
GO

CREATE TABLE dbo.t_apu_mano_obra
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	id_apu			INT NOT NULL,
	id_cuadrilla	INT NOT NULL,
	rendimiento		NUMERIC (5, 2) NOT NULL,
	CONSTRAINT fk_mano_obra_apu FOREIGN KEY (id_apu) REFERENCES dbo.t_apu (ID),
	CONSTRAINT fk_mano_obra_cuadrilla FOREIGN KEY (id_cuadrilla) REFERENCES dbo.t_cuadrilla (ID)
	)
GO