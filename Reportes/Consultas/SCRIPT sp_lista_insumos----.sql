IF OBJECT_ID('dbo.sp_lista_insumos') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.sp_t_cliente
	IF OBJECT_ID('dbo.sp_alertas_tiempos') IS NOT NULL
		PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_lista_insumos>>>'
	ELSE
		PRINT '<<< DROPPED PROCEDURE dbo.sp_lista_insumos >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_lista_insumos
(
	@operacion			VARCHAR(5)				,

	@id					VARCHAR(30)				,
	@usuario			VARCHAR(30)				,
	@fechas				DATETIME		= NULL	,

	-- llegadas tarde, identificar tiempo de demora
	@horario			DATETIME		= NULL	,
	@llegada_trabajo	DATETIME		= NULL
)
WITH ENCRYPTION

AS

	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	IF @fechas = null
	begin
		set @fechas = CONVERT(VARCHAR(10),CURRENT_TIMESTAMP,103)
	end

	SET @operacion = UPPER(@operacion);
	
	----------------------------------------------------------------------
	
	IF @operacion = 'C1'							--> Tiempos de almuerzo
	BEGIN
		
		DECLARE @T_REPORTE_ALMUERZO TABLE 
		(
			usuario				VARCHAR(30)		NOT NULL	,
			dia_actual			DATE			NOT NULL	,
			asistencia			VARCHAR(30)		NULL		,
			salida_almuerzo		TIME			NULL		,
			entrada_almuerzo	TIME			NULL		,
			tipo_permiso		VARCHAR(200)	NULL		,
			nota				VARCHAR(200)	NULL
		)
		DECLARE @fecha DATE = CONVERT(VARCHAR(10), '18/01/2018', 103)
		----------------------------------------------------------------------------------------------------
		-- COMPRUEBA USUARIOS
		INSERT @T_REPORTE_ALMUERZO (usuario, dia_actual)
		SELECT
			B.usuario							,
			@fecha								
		FROM
			t_registro_BIO B
			JOIN t_usuario U	ON U.usuario	= B.usuario
		WHERE
				U.sn_activo = 1
			AND 
				U.usuario	NOT IN('SYSTEM','jvergaram','sforeros')
			AND 
				B.usuario	= U.usuario
		GROUP BY
			B.usuario	
		HAVING COUNT(*) >= 1
		ORDER BY B.usuario DESC
		----------------------------------------------------------------------------------------------------
		-- VERIFICA ASISTENCIA TRABAJO
		UPDATE @T_REPORTE_ALMUERZO
		SET
			asistencia		= 'Ingresó a las' + CONVERT(varchar(30), RIGHT(B.fecha, 7))
		FROM
			@T_REPORTE_ALMUERZO RA
			JOIN t_registro_BIO B	ON RA.usuario	= B.usuario
		WHERE
			B.id_tipo_evento = 1
			AND CONVERT(VARCHAR(10), B.fecha, 103) = @fecha
		----------------------------------------------------------------------------------------------------
		-- NO REGISTRO EN SALIDA ALMUERZO
		UPDATE @T_REPORTE_ALMUERZO
		SET
			salida_almuerzo		= CONVERT(TIME, RIGHT(B.fecha, 7))
		FROM
			@T_REPORTE_ALMUERZO RA
			JOIN t_registro_BIO B	ON RA.usuario	= B.usuario
		WHERE
			B.id_tipo_evento = 4
			AND CONVERT(VARCHAR(10), B.fecha, 103)	= @fecha
		----------------------------------------------------------------------------------------------------
		-- NO REGISTRO EN ENTRADA ALMUERZO
		UPDATE @T_REPORTE_ALMUERZO
		SET
			entrada_almuerzo	= CONVERT(TIME, RIGHT(B.fecha, 7))
		FROM
			@T_REPORTE_ALMUERZO RA
			JOIN t_registro_BIO B	ON RA.usuario	= B.usuario
		WHERE
			B.id_tipo_evento = 5
			AND CONVERT(VARCHAR(10), B.fecha, 103)	= @fecha
		----------------------------------------------------------------------------------------------------
		-- VERIFICA VACACIONES
		UPDATE @T_REPORTE_ALMUERZO
		SET
			tipo_permiso	= 'Vacaciones',
			nota			= V.nota
		FROM
			@T_REPORTE_ALMUERZO RA
			JOIN t_registro_BIO B	ON RA.usuario	= B.usuario
			JOIN t_vacaciones V		ON RA.usuario	= V.usuario
		WHERE
			@fecha BETWEEN V.fecha_inicio AND V.fecha_final
			AND(
				(
					entrada_almuerzo	IS NULL
					OR salida_almuerzo	IS NULL
				)
				OR(
					entrada_almuerzo	IS NOT NULL
					OR salida_almuerzo	IS NOT NULL
				)
			)
		----------------------------------------------------------------------------------------------------
		-- VERIFICA PERMISO TRABAJO CAMPO
		UPDATE @T_REPORTE_ALMUERZO
		SET
			tipo_permiso	= 'Trabajo de campo',
			nota			= TC.nota
		FROM
			@T_REPORTE_ALMUERZO RA
			JOIN t_registro_BIO B	ON RA.usuario	= B.usuario
			JOIN t_trabajo_campo TC	on RA.usuario	= TC.usuario
		WHERE
			CONVERT(VARCHAR(10), @fecha, 103) BETWEEN 
				CONVERT(VARCHAR(10), TC.fecha_inicio, 103) 
				AND CONVERT(VARCHAR(10), TC.fecha_fin, 103)
			AND(
				(
					entrada_almuerzo	IS NULL
					OR salida_almuerzo	IS NULL
				)
				OR(
					entrada_almuerzo	IS NOT NULL
					OR salida_almuerzo	IS NOT NULL
				)
			)
		----------------------------------------------------------------------------------------------------
		-- VERIFICA EL PERMISO PERSONAL
		UPDATE @T_REPORTE_ALMUERZO
		SET
			tipo_permiso	= 'Permiso personal',
			nota			= PP.nota
		FROM
			@T_REPORTE_ALMUERZO RA
			JOIN t_registro_BIO B		ON RA.usuario	= B.usuario
			JOIN t_permiso_personal PP	ON RA.usuario	= PP.usuario
		WHERE
			CONVERT(VARCHAR(10), @fecha, 103) BETWEEN 
				CONVERT(VARCHAR(10), PP.fecha_inicio, 103) 
				AND CONVERT(VARCHAR(10), PP.fecha_fin, 103)
			AND(
				(
					entrada_almuerzo	IS NULL
					OR salida_almuerzo	IS NULL
				)
				OR(
					entrada_almuerzo	IS NOT NULL
					OR salida_almuerzo	IS NOT NULL
				)
			)
		----------------------------------------------------------------------------------------------------
		-- VERIFICA COMPENSATORIO
		UPDATE @T_REPORTE_ALMUERZO
		SET
			tipo_permiso	= 'Compensatorio',
			nota			= C.nota
		FROM
			@T_REPORTE_ALMUERZO RA
			JOIN t_registro_BIO B	ON RA.usuario	= B.usuario
			JOIN t_compensatorio C	ON RA.usuario	= C.usuario
		WHERE
			CONVERT(VARCHAR(10), @fecha, 103) BETWEEN 
				CONVERT(VARCHAR(10), C.fecha_inicio, 103) 
				AND CONVERT(VARCHAR(10), C.fecha_fin, 103)
			AND(
				(
					entrada_almuerzo	IS NULL
					OR salida_almuerzo	IS NULL
				)
				OR(
					entrada_almuerzo	IS NOT NULL
					OR salida_almuerzo	IS NOT NULL
				)
			)

		SELECT * FROM @T_REPORTE_ALMUERZO ORDER BY usuario
	END ELSE
	
	----------------------------------------------------------------------
	
	IF @operacion = 'C2'								--> Llegadas tarde
	BEGIN
		SELECT 
			B.usuario									AS 'Usuario'					,
			TE.nombre									AS 'Tipo de evento'				,
			CONVERT(VARCHAR(10), B.fecha, 103)			AS 'Fecha'						,
			B.nota										AS 'Nota'						,
			RIGHT(B.fecha, 7)							AS 'Hora registro'				,
			RIGHT(HD.hora_inicio,7 )					AS 'Inicio de jornada(Horario)'	,
			DATEDIFF(MINUTE,
				CONVERT(TIME, RIGHT(HD.hora_inicio, 7)),
				CONVERT(TIME, RIGHT(B.fecha, 7))
				)										AS 'Diferencia en minutos'

		FROM 
			t_registro_BIO B
			JOIN t_tipo_evento TE		ON B.id_tipo_evento		= TE.ID
			JOIN t_usuario US			ON B.usuario			= US.usuario
			JOIN t_contrato_rh CR		ON CR.identificacion	= US.usuario
			JOIN t_horario H			ON CR.id_horario		= H.ID
			JOIN t_horario_dias HD		ON H.ID					= HD.id_horario

		WHERE
			TE.ID = 1
			AND
			DATEDIFF(MINUTE,
				CONVERT(TIME, RIGHT(HD.hora_inicio, 7)),
				CONVERT(TIME, RIGHT(B.fecha, 7))
				)
				>= 15
			AND CONVERT(VARCHAR(10), B.fecha, 103)		= 
				CONVERT(VARCHAR(10), DATEADD(wk,DATEDIFF(wk,7,GETDATE()),0), 103) --Primer día de la semana pasada

		GROUP BY 
			B.usuario		, 
			TE.nombre		, 
			B.fecha			, 
			B.nota			, 
			HD.hora_inicio

		HAVING COUNT(*) >= 1

		ORDER BY B.fecha DESC
	END ELSE

	----------------------------------------------------------------------
	
	IF @operacion = 'C3'							--> Memorandos negativos
	BEGIN
		DECLARE @T_MEMORANDO_MES TABLE
		(
			usuario				VARCHAR(30)		NULL					,
			id_memorando		INT				NULL					,
			id_tipo_memorando	INT				NULL					,
			puntosP				INT				NULL					,
			puntosN				INT				NULL
		)
		----------------------------------------------------------------------------------------------------
		-- INSERTA LOS MEMORANDOS DEL USUARIO
		INSERT @T_MEMORANDO_MES (usuario, id_memorando)
		SELECT
			id_para		,
			id		
		FROM
			t_memorandos_rh M
			JOIN t_usuario U				ON M.id_para			= U.usuario
		WHERE
			sn_aceptado = 1
			AND U.sn_activo = 1
			AND U.usuario	NOT IN('SYSTEM','jvergaram','sforeros')  
		----------------------------------------------------------------------------------------------------
		-- VERIFICA EL VALOR DE LOS MEMORANDOS QUE TIENE EL USUSARIO
		UPDATE @T_MEMORANDO_MES
		SET
			id_tipo_memorando	= M.id_tipo_memorando,
			puntosP				= TM.puntos
		FROM
			@T_MEMORANDO_MES MM
			JOIN t_memorandos_rh M			ON MM.id_memorando		= M.id
			JOIN t_tipo_memorando_rh TM		ON M.id_tipo_memorando	= TM.id
		WHERE
			sn_aceptado = 1
			--AND id_para = @USUARIO
			AND TM.puntos > 0
		----------------------------------------------------------------------------------------------------
		-- VERIFICA LOS MEMORANTOS NEGATIVOS POSIBLES
		UPDATE @T_MEMORANDO_MES
		SET
			id_tipo_memorando	= M.id_tipo_memorando,
			puntosN				= TM.puntos
		FROM
			@T_MEMORANDO_MES MM
			JOIN t_memorandos_rh M			ON MM.id_memorando		= M.id
			JOIN t_tipo_memorando_rh TM		ON M.id_tipo_memorando	= TM.id
		WHERE
			sn_aceptado = 1
			--AND id_para = @USUARIO
			AND TM.puntos < 0
		----------------------------------------------------------------------------------------------------
		-- VERIFICA LOS MEMORANDOS POSITIVOS POSIBLES
		UPDATE @T_MEMORANDO_MES
		SET
			id_tipo_memorando	= M.id_tipo_memorando,
			puntosP				= TM.puntos
		FROM
			@T_MEMORANDO_MES MM
			JOIN t_memorandos_rh M			ON MM.id_memorando		= M.id
			JOIN t_tipo_memorando_rh TM		ON M.id_tipo_memorando	= TM.id
		WHERE
			sn_aceptado = 1
			--AND id_para = @USUARIO
			AND TM.puntos > 0
		----------------------------------------------------------------------------------------------------
		-- VERIFICA LOS MEMORANDOS NEUTROS POSIBLES
		UPDATE @T_MEMORANDO_MES
		SET
			id_tipo_memorando	= M.id_tipo_memorando,
			puntosN				= 0
		FROM
			@T_MEMORANDO_MES MM
			JOIN t_memorandos_rh M			ON MM.id_memorando		= M.id
			JOIN t_tipo_memorando_rh TM		ON M.id_tipo_memorando	= TM.id
		WHERE
			puntosN IS NULL
		UPDATE @T_MEMORANDO_MES
		SET
			id_tipo_memorando	= M.id_tipo_memorando,
			puntosP				= 0
		FROM
			@T_MEMORANDO_MES MM
			JOIN t_memorandos_rh M			ON MM.id_memorando		= M.id
			JOIN t_tipo_memorando_rh TM		ON M.id_tipo_memorando	= TM.id
		WHERE
			puntosP IS NULL
		----------------------------------------------------------------------------------------------------
		-- SELECCIÓN FINAL
		SELECT
			LOWER(M.id_para)	AS 'usuario'				,
			COUNT(TM.puntos)	AS 'Total de memorandos'	,
			SUM(puntosP)		AS 'Puntuacion positivos'	,
			SUM(puntosN)		AS 'Puntuacion negativos'	,
			SUM(TM.puntos)		AS 'Total'
		FROM
			@T_MEMORANDO_MES MM
			JOIN t_memorandos_rh M			ON MM.id_memorando		= M.id
			JOIN t_tipo_memorando_rh TM		ON M.id_tipo_memorando	= TM.id
			JOIN t_usuario U				ON M.id_para			= U.usuario
		WHERE
				U.sn_activo = 1
			AND 
				U.usuario	NOT IN('SYSTEM','jvergaram','sforeros')
		GROUP BY 
			M.id_para	
		HAVING COUNT(*) >= 1
	END ELSE

IF OBJECT_ID('dbo.sp_lista_insumos') IS NOT NULL
	PRINT '<<< CREATED PROCEDURE dbo.sp_lista_insumos >>>'
ELSE
	PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_lista_insumos >>>'
GO