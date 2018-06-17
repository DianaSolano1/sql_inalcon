USE prestamos
GO

IF OBJECT_ID ('dbo.t_admin_imprevistos') IS NOT NULL
	DROP TABLE dbo.t_admin_imprevistos
GO

CREATE TABLE dbo.t_admin_imprevistos
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_AIU			INT NOT NULL,
	descripcion		VARCHAR (200) NOT NULL,
	porcentaje		NUMERIC (6, 3) NULL,
	sn_administra	BIT NOT NULL,
	CONSTRAINT fk_admin_imprevistos_AIU FOREIGN KEY (id_AIU) REFERENCES dbo.t_AIU (ID)
	)
GO