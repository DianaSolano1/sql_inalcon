IF OBJECT_ID('dbo.sp_menu') IS NOT NULL
BEGIN
	DROP PROCEDURE dbo.sp_menu
	IF OBJECT_ID('dbo.sp_menu') IS NOT NULL
		PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_menu>>>'
	ELSE
		PRINT '<<< DROPPED PROCEDURE dbo.sp_menu >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE sp_menu
(
	@operacion		VARCHAR(5)		,

	@id				VARCHAR(30)		,
	@contrato		VARCHAR(30)		,
	@descripcion	VARCHAR(500)	,
	@objeto			VARCHAR(300)	,
	@valor_contrato	NUMERIC(18, 2)	
)
WITH ENCRYPTION

AS

	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	----------------------------------------------------------------------
	
	IF @operacion = 'C1'							--> Mostrar contrato en menú principal
	BEGIN
		
		DECLARE @T_TITULO_PRINCIPAL TABLE 
		(
			contrato		VARCHAR(30)		NOT NULL	,
			descripcion		VARCHAR(500)	NOT NULL		
		)
		DECLARE @stringContrato VARCHAR(30) = 'CONTRATO '
		----------------------------------------------------------------------
		-- MENÚ PRINCIPAL
		INSERT @T_TITULO_PRINCIPAL (contrato, descripcion)
		SELECT
			@stringContrato+contrato	,
			descripcion							
		FROM
			t_cliente
		GROUP BY
			contrato	,
			descripcion
		HAVING COUNT(*) >= 1
		ORDER BY contrato DESC

	END ELSE
	
	----------------------------------------------------------------------
	
	IF @operacion = 'C2'							--> Mostrar contrato en menú segundario
	BEGIN
		DECLARE @T_TITULO_SECUNDARIO TABLE
		(
			contrato		VARCHAR(30)		NOT NULL	,
			objeto			VARCHAR(300)	NOT NULL		
		)
		--DECLARE @stringContrato VARCHAR(30) = 'CONTRATO '
		----------------------------------------------------------------------
		-- MENÚ SECUNDARIO
		INSERT @T_TITULO_SECUNDARIO (contrato, objeto)
		SELECT
			@stringContrato+contrato	,
			objeto							
		FROM
			t_cliente
		GROUP BY 
			contrato	,
			objeto
		HAVING COUNT(*) >= 1
		ORDER BY contrato DESC
	END ELSE

IF OBJECT_ID('dbo.sp_menu') IS NOT NULL
	PRINT '<<< CREATED PROCEDURE dbo.sp_menu >>>'
ELSE
	PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_menu >>>'
GO