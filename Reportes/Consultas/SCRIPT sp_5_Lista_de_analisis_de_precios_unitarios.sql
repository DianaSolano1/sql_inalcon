IF OBJECT_ID('dbo.sp_lista_analisis_precios_unitarios') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.sp_lista_analisis_precios_unitarios
	IF OBJECT_ID('dbo.sp_lista_analisis_precios_unitarios') IS NOT NULL
		PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_lista_analisis_precios_unitarios>>>'
	ELSE
		PRINT '<<< DROPPED PROCEDURE dbo.sp_lista_analisis_precios_unitarios >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_lista_analisis_precios_unitarios
(
	@operacion			VARCHAR(5)				
)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	----------------------------------------------------------------------
	
	IF @operacion = 'C1'					--> Consulta datos para reporte de APU
	BEGIN
		
		DECLARE @T_REPORTE_APU TABLE 
		(
			apu					VARCHAR(5)		NOT NULL,
			descripcion			VARCHAR(50)		NOT NULL,
			unidad				VARCHAR (30)	NOT NULL
		)

		INSERT @T_REPORTE_APU (
				apu,
				descripcion,
				unidad)
		SELECT	a.codigo AS 'apu',
				a.nombre AS 'descripcion',
				u.nombre AS 'unidad'
		FROM t_apu a
				LEFT JOIN t_unidades u ON a.id_unidad = u.id
		GROUP BY
			a.codigo			,
			a.nombre			,
			u.nombre				
		HAVING COUNT(*) >= 1
		ORDER BY a.codigo DESC
		
	END ELSE

IF OBJECT_ID('dbo.sp_lista_analisis_precios_unitarios') IS NOT NULL
	PRINT '<<< CREATED PROCEDURE dbo.sp_lista_analisis_precios_unitarios >>>'
ELSE
	PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_lista_analisis_precios_unitarios >>>'
GO