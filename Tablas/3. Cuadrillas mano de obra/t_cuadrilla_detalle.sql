USE prestamos
GO

IF OBJECT_ID ('dbo.t_cuadrilla_detalle') IS NOT NULL
	DROP TABLE dbo.t_cuadrilla_detalle
GO

CREATE TABLE dbo.t_cuadrilla_detalle
	(
	id					INT IDENTITY PRIMARY KEY NOT NULL,
	id_jornal_empleado	INT NOT NULL,
	id_cuadrilla		INT NOT NULL,
	descripcion			VARCHAR (200) NOT NULL,
	cantidad_oficial	INT NOT NULL,
	cantidad_ayudante	INT NOT NULL,
	CONSTRAINT fk_cuadrilla_detalle_jornal_empleado FOREIGN KEY (id_jornal_empleado) REFERENCES dbo.t_jornal_empleado(ID),
	CONSTRAINT fk_cuadrilla_detalle_cuadrilla FOREIGN KEY (id_cuadrilla) REFERENCES dbo.t_cuadrilla(ID)
	)
GO