---------------------------------------------------------------------------
-- sp_t_admin_imprevisto
IF OBJECT_ID('dbo.sp_t_admin_imprevisto') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_admin_imprevisto
    IF OBJECT_ID('dbo.sp_t_admin_imprevisto') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_admin_imprevisto >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_admin_imprevisto >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_admin_imprevisto
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_AIU			INT				= NULL,
	@descripcion	VARCHAR (200)	= NULL,
	@porcentaje		NUMERIC (6, 3)	= NULL,
	@sn_administra	NUMERIC (19,2)	= NULL
)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'							--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 				,
			id_AIU			,
			descripcion		,
			sn_administra	,
			porcentaje
		FROM
			t_admin_imprevistos
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'C2'							--> Consulta ADMINISTRACION IMPREVISTOS Y UTILIDADES
	BEGIN
	
		DECLARE @T_ADMIN_IMPREVISTOS_UTIL TABLE 
		(
			id								INT				NOT NULL,
			admision_imprevistos_utilidades	VARCHAR (200)	NOT NULL,
			valores							NUMERIC (18, 2)	NULL,
			porcentaje						NUMERIC (6, 3)	NULL,
			valor_total						NUMERIC(18, 2)	NULL,
			porcentaje_total				NUMERIC(5, 2)	NULL
		)

		INSERT @T_ADMIN_IMPREVISTOS_UTIL (
				id,
				admision_imprevistos_utilidades,
				valores,
				porcentaje
			)
		SELECT	ai.id,
				ai.descripcion AS 'admision_imprevistos_utilidades',
				(c.valor_contrato * (ai.porcentaje / 100)) AS 'valores',
				ai.porcentaje AS 'porcentaje'
		FROM t_admin_imprevistos ai
				LEFT JOIN t_AIU aiu ON ai.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		ORDER BY ai.id DESC

		UPDATE @T_ADMIN_IMPREVISTOS_UTIL
		SET
			valores	=	(dbo.ValorAdmin())
		FROM
			@T_ADMIN_IMPREVISTOS_UTIL ADM
		WHERE
			valores	IS NULL

		UPDATE @T_ADMIN_IMPREVISTOS_UTIL
		SET
			porcentaje	=	(dbo.PorcentajeAdmin())
		FROM
			@T_ADMIN_IMPREVISTOS_UTIL ADM
		WHERE
			porcentaje	IS NULL

		UPDATE @T_ADMIN_IMPREVISTOS_UTIL
		SET
			valor_total			= (dbo.TotalAIUValor())
		FROM
			@T_ADMIN_IMPREVISTOS_UTIL ADM
		WHERE
			valor_total	IS NULL

		UPDATE @T_ADMIN_IMPREVISTOS_UTIL
		SET
			porcentaje_total	= (dbo.TotalAIUPorcentaje())
		FROM
			@T_ADMIN_IMPREVISTOS_UTIL ADM
		WHERE
			porcentaje_total	IS NULL
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_AIU			,
				descripcion		,
				sn_administra	,
				porcentaje		,
				
				@operacion
			FROM
				t_admin_imprevistos 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_admin_imprevistos 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_admin_imprevistos WHERE id = @id )		
		BEGIN	
				
			UPDATE t_admin_imprevistos 
				SET id_AIU			= ISNULL (@id_AIU, id_AIU),
					descripcion		= ISNULL (@descripcion, descripcion),
					sn_administra	= ISNULL (@sn_administra, sn_administra),
					porcentaje		= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_admin_imprevistos (
				id_AIU			,
				descripcion		,
				sn_administra	,
				porcentaje
			)
			VALUES(
				@id_AIU			,
				@descripcion	,
				@sn_administra	,
				@porcentaje
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_admin_imprevisto') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_admin_imprevisto >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_admin_imprevisto >>>'
GO