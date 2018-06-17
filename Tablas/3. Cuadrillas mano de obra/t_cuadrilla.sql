USE prestamos
GO

IF OBJECT_ID ('dbo.t_cuadrilla') IS NOT NULL
	DROP TABLE dbo.t_cuadrilla
GO

CREATE TABLE dbo.t_cuadrilla
	(
	id					INT IDENTITY PRIMARY KEY NOT NULL,
	id_salario_minimo	INT NOT NULL,
	dias_labor			INT NOT NULL,
	horas_dia			INT NOT NULL,
	CONSTRAINT fk_cuadrilla_salario FOREIGN KEY (id_salario_minimo) REFERENCES dbo.t_legal(ID)
	)
GO