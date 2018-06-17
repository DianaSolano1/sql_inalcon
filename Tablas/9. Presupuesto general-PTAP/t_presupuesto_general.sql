USE prestamos
GO

IF OBJECT_ID ('dbo.t_presupuesto_general') IS NOT NULL
	DROP TABLE dbo.t_presupuesto_general
GO

CREATE TABLE dbo.t_presupuesto_general
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_APU			INT NOT NULL,
	item			INT NOT NULL,
	descripcion		VARCHAR(50) NULL,
	cantidad		INT NULL,
	CONSTRAINT fk_presupuesto_general_APU FOREIGN KEY (id_APU) REFERENCES dbo.t_APU (ID)
	)
GO