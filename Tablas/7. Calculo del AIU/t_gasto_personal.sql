USE prestamos
GO

IF OBJECT_ID ('dbo.t_gasto_personal') IS NOT NULL
	DROP TABLE dbo.t_gasto_personal
GO

CREATE TABLE dbo.t_gasto_personal
	(
	id					INT IDENTITY PRIMARY KEY NOT NULL,
	id_AIU				INT NOT NULL,
	id_empleado			INT NOT NULL,
	cantidad_empleado	INT NOT NULL,
	factor_prestacional	NUMERIC (5, 2) NOT NULL,
	valor				NUMERIC (20, 2) DEFAULT (0) NOT NULL,
	dedicacion			NUMERIC (6, 3) NOT NULL,
	tiempo_obra			NUMERIC (5, 2) NOT NULL,
	CONSTRAINT fk_gastos_personal_AIU FOREIGN KEY (id_AIU) REFERENCES dbo.t_AIU (ID),
	CONSTRAINT fk_gastos_personal_empleado FOREIGN KEY (id_empleado) REFERENCES dbo.t_cargo_sueldo (ID)
	)
GO