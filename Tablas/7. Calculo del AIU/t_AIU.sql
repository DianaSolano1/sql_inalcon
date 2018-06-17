USE prestamos
GO

IF OBJECT_ID ('dbo.t_AIU') IS NOT NULL
	DROP TABLE dbo.t_AIU
GO

CREATE TABLE dbo.t_AIU
	(
	id			INT IDENTITY PRIMARY KEY NOT NULL,
	id_cliente	INT NOT NULL,
	CONSTRAINT fk_AIU_cliente FOREIGN KEY (id_cliente) REFERENCES dbo.t_cliente (ID)
	)
GO