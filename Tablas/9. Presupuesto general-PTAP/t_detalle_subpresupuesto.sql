USE prestamos
GO

IF OBJECT_ID ('dbo.t_detalle_subpresupuesto') IS NOT NULL
	DROP TABLE dbo.t_detalle_subpresupuesto
GO

CREATE TABLE dbo.t_detalle_subpresupuesto
	(
	id					INT IDENTITY PRIMARY KEY NOT NULL,
	id_APU				INT NOT NULL,
	id_presupuesto		INT NOT NULL,
	id_subpresupuesto	INT NOT NULL,
	item				INT NOT NULL,
	cantidad			INT NOT NULL,
	CONSTRAINT fk_detalle_subpresupuesto_AIU FOREIGN KEY (id_APU) REFERENCES dbo.t_APU (ID),
	CONSTRAINT fk_detalle_subpresupuesto_presupuesto FOREIGN KEY (id_presupuesto) REFERENCES dbo.t_presupuesto_general (ID),
	CONSTRAINT fk_detalle_subpresupuesto_subpresupuesto FOREIGN KEY (id_subpresupuesto) REFERENCES dbo.t_subpresupuesto (ID)
	)
GO