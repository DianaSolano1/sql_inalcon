USE prestamos
GO

IF OBJECT_ID ('dbo.t_apu') IS NOT NULL
	DROP TABLE dbo.t_apu
GO

CREATE TABLE dbo.t_apu
	(
	ID					INT IDENTITY PRIMARY KEY NOT NULL,
	codigo				VARCHAR(5) NOT NULL,
	nombre				VARCHAR(50) NOT NULL,
	id_unidad			INT NOT NULL,
	factor_hm			NUMERIC (6, 3) NOT NULL,
	factor_desperdicio	NUMERIC (6, 3) NOT NULL,
	sn_activa			BIT NOT NULL,
	CONSTRAINT fk_apu_unidad FOREIGN KEY (id_unidad) REFERENCES dbo.t_unidades (ID)
	)
GO