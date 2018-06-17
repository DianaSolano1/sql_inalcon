USE prestamos
GO

IF OBJECT_ID ('dbo.t_jornal_empleado') IS NOT NULL
	DROP TABLE dbo.t_jornal_empleado
GO

CREATE TABLE dbo.t_jornal_empleado
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_cuadrilla	INT NOT NULL,
	id_rango		INT NOT NULL,
	descripcion		VARCHAR (200) NOT NULL,
	sn_ayudante		BIT NOT NULL,
	porcentaje		NUMERIC (6, 2) NOT NULL,
	CONSTRAINT fk_jornal_empleado_cuadrilla FOREIGN KEY (id_cuadrilla) REFERENCES dbo.t_cuadrilla(ID),
	CONSTRAINT fk_jornal_empleado_rango FOREIGN KEY (id_rango) REFERENCES dbo.t_rango(ID)
	)
GO

select * from t_jornal_empleado