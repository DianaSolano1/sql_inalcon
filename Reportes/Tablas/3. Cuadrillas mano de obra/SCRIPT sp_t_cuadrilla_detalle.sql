-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_cuadrilla_detalle') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_cuadrilla_detalle
    IF OBJECT_ID('dbo.sp_t_cuadrilla_detalle') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_cuadrilla_detalle >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_cuadrilla_detalle >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_cuadrilla_detalle
(
	@operacion			VARCHAR(5),

	@id					INT				= NULL,
	@id_jornal_empleado	INT				= NULL,
	@id_cuadrilla		INT				= NULL,
	@descripcion		VARCHAR(200)	= NULL,
	@cantidad_oficial	INT				= NULL,
	@cantidad_ayudante	INT				= NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'					--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 					,
			id_jornal_empleado	,
			id_cuadrilla		,
			descripcion			,
			cantidad_oficial	,
			cantidad_ayudante
		FROM
			t_cuadrilla_detalle
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE

	IF @operacion = 'C2'					--> Consulta de cuadrillas 
	BEGIN
		DECLARE @T_CUADRILLA TABLE
		(
			id_jornal_empleado		INT				NOT NULL,
			descripcion_cuadrillas	VARCHAR (200)	NOT NULL,
			cantidad_oficial		INT				NOT NULL,
			cantidad_ayudante		INT				NOT NULL,
			valor_jornal			NUMERIC(18,2)	NULL	,
			valor_jornal_prestacion	NUMERIC(18,2)	NULL	,
			cuadrilla_h_prestacion	NUMERIC(18,2)	NULL	
		)

		INSERT @T_CUADRILLA (
			id_jornal_empleado,
			descripcion_cuadrillas,
			cantidad_oficial,
			cantidad_ayudante,
			valor_jornal)
		SELECT
			cdet.id_jornal_empleado,
			cdet.descripcion AS 'descripcion_cuadrillas',
			cdet.cantidad_oficial,
			cdet.cantidad_ayudante,
			(
				-- para el de oficial
				(cdet.cantidad_oficial * dbo.ObtenerValorJornal(cdet.id_jornal_empleado,  1))
				+
				-- para el de ayudante
				(cdet.cantidad_ayudante * dbo.ObtenerValorJornal(cdet.id_jornal_empleado, 0))
			) as 'valor_jornal_ayudante'

		FROM t_cuadrilla_detalle cdet
			LEFT JOIN t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
		ORDER BY cdet.descripcion DESC;
		
		UPDATE @T_CUADRILLA
		SET
			valor_jornal_prestacion	=	(valor_jornal * dbo.calcularFactorMultiplicadorTotal())
		FROM
			@T_CUADRILLA CFM
		WHERE
			valor_jornal_prestacion	IS NULL

		UPDATE @T_CUADRILLA
		SET
			cuadrilla_h_prestacion	=	(CFM.valor_jornal_prestacion * c.horas_dia)
		FROM
			@T_CUADRILLA CFM
			LEFT JOIN t_jornal_empleado je ON CFM.id_jornal_empleado = je.id
			LEFT JOIN t_cuadrilla c ON je.id_cuadrilla = c.id
		WHERE
			cuadrilla_h_prestacion	IS NULL

	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_jornal_empleado	,
				id_cuadrilla		,
				descripcion			,
				cantidad_oficial	,
				cantidad_ayudante	,
				
				@operacion
			FROM
				t_cuadrilla_detalle 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_cuadrilla_detalle 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_cuadrilla_detalle WHERE id = @id )		
		BEGIN	
				
			UPDATE t_cuadrilla_detalle 
				SET id_jornal_empleado	= ISNULL (@id_jornal_empleado, id_jornal_empleado),
					id_cuadrilla		= ISNULL (@id_cuadrilla, id_cuadrilla),
					descripcion			= ISNULL (@descripcion, descripcion),
					cantidad_oficial	= ISNULL (@cantidad_oficial, cantidad_oficial),
					cantidad_ayudante	= ISNULL (@cantidad_ayudante, cantidad_ayudante)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_cuadrilla_detalle (
				id_jornal_empleado	,
				id_cuadrilla		,
				descripcion			,
				cantidad_oficial	,
				cantidad_ayudante	
			)
			VALUES (
				@id_jornal_empleado	,
				@id_cuadrilla		,
				@descripcion		,
				@cantidad_oficial	,
				@cantidad_ayudante
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_cuadrilla_detalle') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_cuadrilla_detalle >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_cuadrilla_detalle >>>'
GO