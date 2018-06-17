IF OBJECT_ID('dbo.sp_calculo_factor_multiplicador') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.sp_calculo_factor_multiplicador
	IF OBJECT_ID('dbo.sp_calculo_factor_multiplicador') IS NOT NULL
		PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_calculo_factor_multiplicador>>>'
	ELSE
		PRINT '<<< DROPPED PROCEDURE dbo.sp_calculo_factor_multiplicador >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_calculo_factor_multiplicador
(
	@operacion			VARCHAR(5)				
)
WITH ENCRYPTION

AS

	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	----------------------------------------------------------------------
	
	IF @operacion = 'C1'							--> Cálculo FM
	BEGIN
		
		DECLARE @T_CALCULO_FM TABLE 
		(
			item_capitulo VARCHAR (5) NOT NULL,
			capitulo VARCHAR (200) NOT NULL,
			porcentaje_capitulo INT NULL,
			item_subcapitulo VARCHAR (5) NULL,
			subcapitulo VARCHAR (200) NULL,
			porcentaje_subcapitulo NUMERIC (5, 2) NULL,
			item VARCHAR (200) NULL,
			porcentaje_item NUMERIC (5, 2) NULL
		)
		----------------------------------------------------------------------------------------------------
		-- GUARDA LOS DATOS PARA LA TABLA
		INSERT @T_CALCULO_FM (
						item_capitulo, 
						capitulo, 
						porcentaje_capitulo, 
						item_subcapitulo, 
						subcapitulo, 
						porcentaje_subcapitulo, 
						item, 
						porcentaje_item)
		SELECT	b.item AS 'item_capitulo',
				b.nombre AS 'capitulo',
				b.porcentaje AS 'porcentaje_capitulo',
				s.item AS 'item_subcapitulo',
				s.nombre AS 'subcapitulo',
				s.porcentaje AS 'porcentaje_subcapitulo',
				d.nombre AS 'item',
				d.porcentaje AS 'porcentaje_item'
		FROM t_factor_base b
			LEFT JOIN t_factor_subitem s ON b.ID = s.id_factor_base
			LEFT JOIN t_factor_detalle d ON s.ID = d.id_factor_subitem
		GROUP BY
			b.item			,
			b.nombre		,
			b.porcentaje	,
			s.item			,
			s.nombre		,
			s.porcentaje	,
			d.nombre		,
			d.porcentaje
		HAVING COUNT(*) >= 1
		ORDER BY b.item DESC
		
	END ELSE

IF OBJECT_ID('dbo.sp_calculo_factor_multiplicador') IS NOT NULL
	PRINT '<<< CREATED PROCEDURE dbo.sp_calculo_factor_multiplicador >>>'
ELSE
	PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_calculo_factor_multiplicador >>>'
GO