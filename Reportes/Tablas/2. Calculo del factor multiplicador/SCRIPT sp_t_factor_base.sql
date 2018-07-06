-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_factor_base
IF OBJECT_ID('dbo.sp_t_factor_base') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_factor_base
    IF OBJECT_ID('dbo.sp_t_factor_base') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_factor_base >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_factor_base >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_factor_base
(
	@operacion		VARCHAR(5),

	@id				INT 			= NULL,
	@item			VARCHAR (5)		= NULL,
	@nombre			VARCHAR (200)    = NULL,
	@porcentaje		INT				= NULL

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
			item		,
			nombre		,
			porcentaje		
		FROM
			t_factor_base
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	
	
	IF @operacion = 'C2'							--> Consulta de APUS
	BEGIN
		DECLARE @T_CALCULO_FM TABLE 
		(
			item_capitulo			VARCHAR (5)		NOT NULL,
			capitulo				VARCHAR (200)	NOT NULL,
			porcentaje_capitulo		NUMERIC (5, 2)	NULL,
			item_subcapitulo		VARCHAR (5)		NULL,
			subcapitulo				VARCHAR (200)	NULL,
			porcentaje_subcapitulo	NUMERIC (5, 2)	NULL,
			item					VARCHAR (200)	NULL,
			porcentaje_item			NUMERIC (5, 2)	NULL,
			factor_multiplicador	NUMERIC(5, 2)	NULL
		)
		INSERT @T_CALCULO_FM (
			item_capitulo, 
			capitulo, 
			porcentaje_capitulo, 
			item_subcapitulo, 
			subcapitulo, 
			porcentaje_subcapitulo, 
			item, 
			porcentaje_item,
			factor_multiplicador)
		SELECT	
			b.item AS 'item_capitulo',
			b.nombre AS 'capitulo',
			b.porcentaje AS 'porcentaje_capitulo',
			s.item AS 'item_subcapitulo',
			s.nombre AS 'subcapitulo',
			s.porcentaje AS 'porcentaje_subcapitulo',
			d.nombre AS 'item',
			d.porcentaje AS 'porcentaje_item',
			dbo.calcularFactorMultiplicador(b.item) as 'factor_multiplicador'
		FROM t_factor_base b
			LEFT JOIN t_factor_subitem s ON b.ID = s.id_factor_base
			LEFT JOIN t_factor_detalle d ON s.ID = d.id_factor_subitem
		ORDER BY b.item DESC

		UPDATE @T_CALCULO_FM
		SET
			porcentaje_capitulo	= dbo.calcularFactorMultiplicador(item_capitulo)
		FROM
			@T_CALCULO_FM CFM
		WHERE
			porcentaje_capitulo	IS NULL

		SELECT * FROM @T_CALCULO_FM

	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 			,
				item		,
				nombre		,
				porcentaje	,		

				@operacion
			FROM
				t_factor_base 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_factor_base
				WHERE
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_factor_base WHERE id = @id )		
		BEGIN	
				
			UPDATE t_factor_base 
				SET item		= ISNULL (@item, item),
					nombre		= ISNULL (@nombre, nombre),
					porcentaje	= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_factor_base (
				item		,
				nombre		,
				porcentaje					
			)
			VALUES(
				@item		,
				@nombre		,
				@porcentaje				
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_factor_base') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_factor_base >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_factor_base >>>'
GO