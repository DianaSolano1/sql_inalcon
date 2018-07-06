-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_costos_interventoria
IF OBJECT_ID('dbo.sp_costos_interventoria') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_costos_interventoria
    IF OBJECT_ID('dbo.sp_costos_interventoria') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_costos_interventoria >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_costos_interventoria >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_costos_interventoria
(
	@operacion		VARCHAR(5)

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'							--> Consulta el total de los costos de interventoria
	BEGIN
	
		DECLARE @T_SUPERVISION_INTERVENTORIA TABLE 
		(
			total_costos_interventoria	NUMERIC (18, 2)	NOT NULL,
			mas_iva						NUMERIC (18, 2)	NOT NULL,
			costo_total					NUMERIC (18, 2)	NOT NULL
		)

		INSERT @T_SUPERVISION_INTERVENTORIA (
				total_costos_interventoria,
				mas_iva,
				costo_total
			)
		SELECT	dbo.TotalCostosInterventoria() AS Total_Costos_Interventoria,
				dbo.TotalCostosMasIva() AS Total_Costos_De_Iva,
				dbo.TotalCostos() AS Total_Costos

		SELECT * FROM @T_SUPERVISION_INTERVENTORIA
	
	END
GO

IF OBJECT_ID('dbo.sp_costos_interventoria') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_costos_interventoria >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_costos_interventoria >>>'
GO