USE prestamos
GO

IF OBJECT_ID ('dbo.t_subpresupuesto') IS NOT NULL
	DROP TABLE dbo.t_subpresupuesto
GO

CREATE TABLE dbo.t_subpresupuesto
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	id_APU			INT NOT NULL,
	id_presupuesto	INT NOT NULL,
	item			INT NOT NULL,
	descripcion		INT NULL,
	cantidad		INT NULL,
	CONSTRAINT fk_subpresupuesto_AIU FOREIGN KEY (id_APU) REFERENCES dbo.t_APU (ID),
	CONSTRAINT fk_subpresupuesto_presupuesto FOREIGN KEY (id_presupuesto) REFERENCES dbo.t_presupuesto_general (ID),
	)
GO