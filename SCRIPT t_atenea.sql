CREATE DATABASE atenea;
GO
USE atenea
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

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_unidad') IS NOT NULL
	DROP TABLE dbo.t_unidad
GO

CREATE TABLE dbo.t_unidad
	(
	id			INT IDENTITY PRIMARY KEY NOT NULL,
	nombre		VARCHAR (30) NOT NULL
	)
GO


-------------------------------------------------------
IF OBJECT_ID ('dbo.t_procedencia') IS NOT NULL
	DROP TABLE dbo.t_procedencia
GO

CREATE TABLE dbo.t_procedencia
	(
	id			INT IDENTITY PRIMARY KEY NOT NULL,
	nombre		VARCHAR (30) NOT NULL 
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_legal') IS NOT NULL
	DROP TABLE dbo.t_legal
GO

CREATE TABLE dbo.t_legal
	(
	id			INT IDENTITY PRIMARY KEY NOT NULL,
	nombre		VARCHAR (30) NOT NULL,
	anno		DATE NOT NULL,
	valor		NUMERIC (18, 2) DEFAULT (0) NOT NULL
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_producto') IS NOT NULL
	DROP TABLE dbo.t_producto
GO

CREATE TABLE dbo.t_producto
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_unidad		INT NOT NULL,
	id_procedencia	INT NOT NULL,
	id_iva			INT NOT NULL,
	nombre			VARCHAR (200) NOT NULL,
	valor			NUMERIC (18, 2) DEFAULT (0) NULL,
	sn_iva			BIT NOT NULL,
	CONSTRAINT fk_producto_unidad FOREIGN KEY (id_unidad) REFERENCES dbo.t_unidad (ID),
	CONSTRAINT fk_producto_procedencia FOREIGN KEY (id_procedencia) REFERENCES dbo.t_procedencia (ID),
	CONSTRAINT fk_producto_legal FOREIGN KEY (id_iva) REFERENCES dbo.t_legal (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_factor_base') IS NOT NULL
	DROP TABLE dbo.t_factor_base
GO

CREATE TABLE dbo.t_factor_base
	(
	ID					INT IDENTITY PRIMARY KEY NOT NULL,
	item				VARCHAR (5) NOT NULL,
	nombre				VARCHAR (200) NOT NULL,
	porcentaje			INT NULL
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_factor_subitem') IS NOT NULL
	DROP TABLE dbo.t_factor_subitem
GO

CREATE TABLE dbo.t_factor_subitem
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	id_factor_base	INT NOT NULL,
	item			VARCHAR (5) NULL,
	nombre			VARCHAR (200) NULL,
	porcentaje		NUMERIC (5, 2) NULL,
	CONSTRAINT fk_factor_subitem_base FOREIGN KEY (id_factor_base) REFERENCES dbo.t_factor_base (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_factor_detalle') IS NOT NULL
	DROP TABLE dbo.t_factor_detalle
GO

CREATE TABLE dbo.t_factor_detalle
	(
	ID					INT IDENTITY PRIMARY KEY NOT NULL,
	id_factor_subitem	INT NOT NULL,
	nombre				VARCHAR (200) NOT NULL,
	porcentaje			NUMERIC (5, 2) NULL, 
	CONSTRAINT fk_factor_subitem_subitem FOREIGN KEY (id_factor_subitem) REFERENCES dbo.t_factor_subitem (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_rango') IS NOT NULL
	DROP TABLE dbo.t_rango
GO

CREATE TABLE dbo.t_rango
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	nombre			VARCHAR(30) NOT NULL
	)
GO

-------------------------------------------------------
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

-------------------------------------------------------
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

-------------------------------------------------------
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

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_apu') IS NOT NULL
	DROP TABLE dbo.t_apu
GO

CREATE TABLE dbo.t_apu
	(
	ID					INT IDENTITY PRIMARY KEY NOT NULL,
	codigo				VARCHAR(5) NOT NULL,
	nombre				VARCHAR(50) NOT NULL,
	id_unidad			INT NOT NULL,
	factor_hm			NUMERIC (6, 3) NOT NULL,
	factor_desperdicio	NUMERIC (6, 3) NOT NULL,
	sn_activa			BIT NOT NULL,
	CONSTRAINT fk_apu_unidad FOREIGN KEY (id_unidad) REFERENCES dbo.t_unidad (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_apu_mano_obra') IS NOT NULL
	DROP TABLE dbo.t_apu_mano_obra
GO

CREATE TABLE dbo.t_apu_mano_obra
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	id_apu			INT NOT NULL,
	id_cuadrilla	INT NOT NULL,
	rendimiento		NUMERIC (5, 2) NOT NULL,
	CONSTRAINT fk_mano_obra_apu FOREIGN KEY (id_apu) REFERENCES dbo.t_apu (ID),
	CONSTRAINT fk_mano_obra_cuadrilla FOREIGN KEY (id_cuadrilla) REFERENCES dbo.t_cuadrilla (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_apu_material') IS NOT NULL
	DROP TABLE dbo.t_apu_material
GO

CREATE TABLE dbo.t_apu_material
	(
	ID			INT IDENTITY PRIMARY KEY NOT NULL,
	id_apu		INT NOT NULL,
	id_producto	INT NOT NULL,
	cantidad	NUMERIC (5, 2) NOT NULL,
	CONSTRAINT fk_material_apu FOREIGN KEY (id_apu) REFERENCES dbo.t_apu (ID),
	CONSTRAINT fk_material_producto FOREIGN KEY (id_producto) REFERENCES dbo.t_producto (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_apu_transporte_material') IS NOT NULL
	DROP TABLE dbo.t_apu_transporte_material
GO

CREATE TABLE dbo.t_apu_transporte_material
	(
	ID			INT IDENTITY PRIMARY KEY NOT NULL,
	id_apu		INT NOT NULL,
	id_producto	INT NOT NULL,
	distancia	NUMERIC (10, 2) NOT NULL,
	tarifa		NUMERIC (10, 2) DEFAULT (0) NOT NULL,
	CONSTRAINT fk_transporte_material_apu FOREIGN KEY (id_apu) REFERENCES dbo.t_apu (ID),
	CONSTRAINT fk_transporte_material_producto FOREIGN KEY (id_producto) REFERENCES dbo.t_producto (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_apu_equipo') IS NOT NULL
	DROP TABLE dbo.t_apu_equipo
GO

CREATE TABLE dbo.t_apu_equipo
	(
	ID			INT IDENTITY PRIMARY KEY NOT NULL,
	id_apu		INT NOT NULL,
	id_producto	INT NOT NULL,
	cantidad	NUMERIC (5, 2) NOT NULL,
	rendimiento	NUMERIC (5, 2) NOT NULL,
	CONSTRAINT fk_equipo_apu FOREIGN KEY (id_apu) REFERENCES dbo.t_apu (ID),
	CONSTRAINT fk_equipo_producto FOREIGN KEY (id_producto) REFERENCES dbo.t_producto (ID)
	)
GO

-------------------------------------------------------
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

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_impuesto') IS NOT NULL
	DROP TABLE dbo.t_impuesto
GO

CREATE TABLE dbo.t_impuesto
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_AIU			INT NOT NULL,
	descripcion		VARCHAR (200) NOT NULL,
	porcentaje		NUMERIC (6, 3) NOT NULL,
	CONSTRAINT fk_impuesto_AIU FOREIGN KEY (id_AIU) REFERENCES dbo.t_AIU (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_gasto_legal') IS NOT NULL
	DROP TABLE dbo.t_gasto_legal
GO

CREATE TABLE dbo.t_gasto_legal
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_AIU			INT NOT NULL,
	descripcion		VARCHAR (200) NOT NULL,
	valores			NUMERIC (19, 2) NULL,
	porcentaje		NUMERIC (6, 3) NULL,
	CONSTRAINT fk_gasto_legal_AIU FOREIGN KEY (id_AIU) REFERENCES dbo.t_AIU (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_gasto_campo_oficina') IS NOT NULL
	DROP TABLE dbo.t_gasto_campo_oficina
GO

CREATE TABLE dbo.t_gasto_campo_oficina
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_AIU			INT NOT NULL,
	descripcion		VARCHAR (200) NOT NULL,
	valor			NUMERIC (19, 3) DEFAULT (0) NOT NULL,
	dedicacion		NUMERIC (6, 3) NOT NULL,
	tiempo_obra		NUMERIC (5, 2) NOT NULL,
	CONSTRAINT fk_gasto_campo_oficina_AIU FOREIGN KEY (id_AIU) REFERENCES dbo.t_AIU (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_admin_imprevisto') IS NOT NULL
	DROP TABLE dbo.t_admin_imprevisto
GO

CREATE TABLE dbo.t_admin_imprevisto
	(
	id				INT IDENTITY PRIMARY KEY NOT NULL,
	id_AIU			INT NOT NULL,
	descripcion		VARCHAR (200) NOT NULL,
	porcentaje		NUMERIC (6, 3) NULL,
	sn_administra	BIT NOT NULL,
	CONSTRAINT fk_admin_imprevisto_AIU FOREIGN KEY (id_AIU) REFERENCES dbo.t_AIU (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_experiencia') IS NOT NULL
	DROP TABLE dbo.t_experiencia
GO

CREATE TABLE dbo.t_experiencia
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	nombre			VARCHAR (100) NOT NULL
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_rol_cargo') IS NOT NULL
	DROP TABLE dbo.t_rol_cargo
GO

CREATE TABLE dbo.t_rol_cargo
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	nombre			VARCHAR (100) NOT NULL
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_cargo_sueldo') IS NOT NULL
	DROP TABLE dbo.t_cargo_sueldo
GO

CREATE TABLE dbo.t_cargo_sueldo
	(
	ID				INT IDENTITY PRIMARY KEY NOT NULL,
	id_rol			INT NOT NULL,
	nombre			VARCHAR (100) NOT NULL,
	sueldo_basico	NUMERIC (18, 2) DEFAULT (0) NOT NULL,
	CONSTRAINT fk_cargo_rol FOREIGN KEY (id_rol) REFERENCES dbo.t_rol_cargo (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_costo_personal') IS NOT NULL
	DROP TABLE dbo.t_costo_personal
GO

CREATE TABLE dbo.t_costo_personal
	(
	ID					INT IDENTITY PRIMARY KEY NOT NULL,
	id_experiencia		INT NOT NULL,
	id_cargo			INT NOT NULL,
	cantidad			INT NOT NULL,
	dedicacion			NUMERIC (6, 3) NOT NULL,
	tiempo_ejecucion	INT NOT NULL,
	CONSTRAINT fk_costo_personal_experiencia FOREIGN KEY (id_experiencia) REFERENCES dbo.t_experiencia (ID),
	CONSTRAINT fk_costo_personal_cargo FOREIGN KEY (id_cargo) REFERENCES dbo.t_cargo_sueldo (ID)
	)
GO

-------------------------------------------------------
IF OBJECT_ID ('dbo.t_costo_directo') IS NOT NULL
	DROP TABLE dbo.t_costo_directo
GO

CREATE TABLE dbo.t_costo_directo
	(
	id					INT IDENTITY PRIMARY KEY NOT NULL,
	id_unidad			INT NOT NULL,
	nombre				VARCHAR (200) NOT NULL,
	cantidad			INT NOT NULL,
	dedicacion			NUMERIC (6, 3) NOT NULL,
	tiempo_ejecucion	INT NOT NULL,
	tarifa				NUMERIC (18, 2) NOT NULL,
	CONSTRAINT fk_costo_directo_unidad FOREIGN KEY (id_unidad) REFERENCES dbo.t_unidad (ID)
	)
GO

-------------------------------------------------------
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
	CONSTRAINT fk_gasto_personal_AIU FOREIGN KEY (id_AIU) REFERENCES dbo.t_AIU (ID),
	CONSTRAINT fk_gasto_personal_empleado FOREIGN KEY (id_empleado) REFERENCES dbo.t_cargo_sueldo (ID)
	)
GO

-------------------------------------------------------
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

-------------------------------------------------------
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

-------------------------------------------------------
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