---------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_impuestos') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_impuestos
    IF OBJECT_ID('dbo.sp_t_impuestos') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_impuestos >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_impuestos >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_impuestos
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_AIU			INT				= NULL,
	@descripcion	VARCHAR (200)	= NULL,
	@porcentaje		NUMERIC (6, 3)	= NULL
)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'							--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 			,
			id_AIU		,
			descripcion	,
			porcentaje
		FROM
			t_impuestos
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE

	IF @operacion = 'C2'							--> Consulta de impuestos
	BEGIN
	
		SELECT	i.id,
				i.descripcion AS 'impuestos',
				((i.porcentaje / 100) * c.valor_contrato) AS 'valores',
				i.porcentaje AS 'porcentaje',
				dbo.ImpuestosSTI() AS 'ImpuestosSTI',
				dbo.ImpuestosTotalPorcentajes() AS 'ImpuestosTotalPorcentajes'
		FROM t_impuestos i
				LEFT JOIN t_AIU aiu ON i.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		ORDER BY i.id 
	
	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 			,
				id_AIU		,
				descripcion	,
				porcentaje	,
				
				@operacion
			FROM
				t_impuestos 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_impuestos 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_impuestos WHERE id = @id )		
		BEGIN	
				
			UPDATE t_impuestos 
				SET id_AIU		= ISNULL (@id_AIU, id_AIU),
					descripcion	= ISNULL (@descripcion, descripcion),
					porcentaje	= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_impuestos (
				id_AIU		,
				descripcion	,
				porcentaje
			)
			VALUES(
				@id_AIU			,
				@descripcion	,
				@porcentaje
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_impuestos') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_impuestos >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_impuestos >>>'
GO