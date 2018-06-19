IF OBJECT_ID('dbo.sp_cuadrillas_mano_obra') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.sp_cuadrillas_mano_obra
	IF OBJECT_ID('dbo.sp_cuadrillas_mano_obra') IS NOT NULL
		PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_cuadrillas_mano_obra>>>'
	ELSE
		PRINT '<<< DROPPED PROCEDURE dbo.sp_cuadrillas_mano_obra >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_cuadrillas_mano_obra
(
	@operacion			VARCHAR(5)				
)
WITH ENCRYPTION

AS

	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	----------------------------------------------------------------------
	
	IF @operacion = 'C1'							--> Consulta para la cuadrilla principal
	BEGIN
		
		----------------------------------------------------------------------------------------------------
		-- CREA TABLA PRINCIPAL PARA CUADRILLA
		DECLARE @T_PRINCIPAL_CUADRILLA TABLE 
		(
			salario_minimo			NUMERIC (18, 2)	NOT NULL,
			dias_laborales			INT				NOT NULL,
			horas_dia				INT				NOT NULL
		)
		INSERT @T_PRINCIPAL_CUADRILLA (
				salario_minimo,
				dias_laborales,
				horas_dia)
		SELECT	l.valor AS 'salario_minimo',
				c.dias_labor AS 'dias_laborales',
				c.horas_dia
		FROM t_cuadrilla c
				LEFT JOIN t_legal l ON c.id_salario_minimo = l.id
		GROUP BY
			l.valor			,
			c.dias_labor	,
			c.horas_dia		
		HAVING COUNT(*) >= 1
		ORDER BY l.valor DESC
		
	END ELSE

	----------------------------------------------------------------------
	
	IF @operacion = 'C2'								--> C�lculo para el jornal de los empleados
	BEGIN

		----------------------------------------------------------------------------------------------------
		-- TABLA JORNAL EMPLEADO (OFICIAL, AYUDANTE)
		DECLARE @T_JORNAL_EMPLEADO TABLE 
		(
			descripcion				VARCHAR (200)	NOT NULL,
			porcentaje				NUMERIC (6, 2)	NOT NULL,
			salario_minimo			NUMERIC (18, 2)	NOT NULL,
			dias_laborales			INT				NOT NULL,
			valor_jornal			NUMERIC (18, 2)	NOT NULL,
			cargo					BIT				NOT NULL
		)
		
		INSERT @T_JORNAL_EMPLEADO (
				descripcion,
				porcentaje,
				salario_minimo,
				dias_laborales,
				valor_jornal,
				cargo)
		SELECT	je.descripcion,
				je.porcentaje,
				cl.valor AS 'salario_minimo',
				cd.dias_labor AS 'dias_laborales',
				((1 + (je.porcentaje / 100)) * (cl.valor / cd.dias_labor)) AS 'valor_jornal',
				--(1 + (je.porcentaje / 100)) AS 'porcentaje+1',
				--(cl.valor / cd.dias_labor) AS 'salario/dias',
				je.sn_ayudante AS 'cargo'
		FROM t_jornal_empleado je
				LEFT JOIN t_cuadrilla cd ON je.id_cuadrilla = cd.id
				LEFT JOIN t_legal cl ON cd.id_salario_minimo = cl.id
		GROUP BY
			je.descripcion	,
			je.porcentaje	,
			cl.valor		,
			cd.dias_labor	,
			je.sn_ayudante
		HAVING COUNT(*) >= 1
		ORDER BY je.descripcion DESC

	END ELSE

	----------------------------------------------------------------------
	
	IF @operacion = 'C3'								--> Reporte final de las cuadrillas
	BEGIN

		----------------------------------------------------------------------------------------------------
		-- DESCRIPCION CUADRILLA
		DECLARE @T_CUADRILLAS TABLE 
		(
			id_jornal_empleado		INT				NOT NULL,
			descripcion_cuadrillas	VARCHAR (200)	NOT NULL,
			cantidad_oficial		INT				NOT NULL,
			cantidad_ayudante		INT				NOT NULL
		)
		INSERT @T_CUADRILLAS (
				id_jornal_empleado		,
				descripcion_cuadrillas	,
				cantidad_oficial		,
				cantidad_ayudante)
		SELECT	cdet.id_jornal_empleado,
				cdet.descripcion AS 'descripcion_cuadrillas',
				cdet.cantidad_oficial,
				cdet.cantidad_ayudante
		FROM t_cuadrilla_detalle cdet
				LEFT JOIN t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
		GROUP BY
			cdet.id_jornal_empleado	,
			cdet.descripcion		,
			cdet.cantidad_oficial	,
			cdet.cantidad_ayudante
		HAVING COUNT(*) >= 1
		ORDER BY cdet.descripcion DESC

	END ELSE
IF OBJECT_ID('dbo.sp_cuadrillas_mano_obra') IS NOT NULL
	PRINT '<<< CREATED PROCEDURE dbo.sp_cuadrillas_mano_obra >>>'
ELSE
	PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_cuadrillas_mano_obra >>>'
GO