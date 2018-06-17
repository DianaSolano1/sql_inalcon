USE prestamos
GO

IF OBJECT_ID ('dbo.t_lista_analisis') IS NOT NULL
	DROP TABLE dbo.t_lista_analisis
GO

CREATE TABLE dbo.t_lista_analisis
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_apu			INT NOT NULL,
	descripcion		VARCHAR(300) NOT NULL,
	CONSTRAINT fk_lista_analisis_apu FOREIGN KEY (id_apu) REFERENCES dbo.t_apu (ID),
	)
GO