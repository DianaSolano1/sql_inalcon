CREATE DATABASE prestamos;
GO
USE prestamos
GO

IF OBJECT_ID ('dbo.t_cliente') IS NOT NULL
	DROP TABLE dbo.t_cliente
GO

CREATE TABLE dbo.t_cliente
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	contrato		VARCHAR (30) NOT NULL,
	descripcion		VARCHAR (500) NOT NULL,
	objeto			VARCHAR (300) NOT NULL,
	valor_contrato	NUMERIC (18, 2) DEFAULT (0) NOT NULL
	)
GO