---------------------------------------------------------------------------
-- sp_t_detalle_subpresupuesto
IF OBJECT_ID('dbo.sp_t_detalle_subpresupuesto') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_detalle_subpresupuesto
    IF OBJECT_ID('dbo.sp_t_detalle_subpresupuesto') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_detalle_subpresupuesto >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_detalle_subpresupuesto >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_detalle_subpresupuesto
(
	@operacion		VARCHAR(5),

	@id					INT	= NULL,
	@id_APU				INT	= NULL,
	@id_presupuesto		INT	= NULL,
	@id_subpresupuesto	INT = NULL,
	@item				INT	= NULL,
	@cantidad			INT	= NULL
)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'							--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 					,
			id_APU				,
			id_presupuesto		,
			id_subpresupuesto	,
			item				,
			cantidad
		FROM
			t_detalle_subpresupuesto
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE

	IF @operacion = 'C2'							--> Consulta el detalle del subpresupuesto
	BEGIN
	
		SELECT	pg.item,
				s.item,
				ds.item,
				apu.codigo,
				apu.nombre,
				u.nombre,
				dbo.TotalApuInicial(apu.codigo) AS TotalApuInicial,
				ds.cantidad,
				dbo.ValorTotalDETAPULleno(apu.codigo,ds.item) AS ValorTotalDETAPULleno
		FROM t_detalle_subpresupuesto ds
				LEFT JOIN t_subpresupuesto s ON ds.id_subpresupuesto = s.ID
				LEFT JOIN t_presupuesto_general pg ON ds.id_presupuesto = pg.id
				LEFT JOIN t_apu apu ON ds.id_APU = apu.ID
				LEFT JOIN t_unidad u ON apu.id_unidad = u.id
		ORDER BY pg.item
	
	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_APU				,
				id_presupuesto		,
				id_subpresupuesto	,
				item				,
				cantidad			,
				
				@operacion
			FROM
				t_detalle_subpresupuesto 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_detalle_subpresupuesto 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_detalle_subpresupuesto WHERE id = @id )		
		BEGIN	
				
			UPDATE t_detalle_subpresupuesto 
				SET id_APU				= ISNULL (@id_APU, id_APU),
					id_presupuesto		= ISNULL (@id_presupuesto, id_presupuesto),
					id_subpresupuesto	= ISNULL (@id_subpresupuesto, id_subpresupuesto),
					item				= ISNULL (@item, item),
					cantidad			= ISNULL (@cantidad, cantidad)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_detalle_subpresupuesto (
				id 					,
				id_APU				,
				id_presupuesto		,
				id_subpresupuesto	,
				item				,
				cantidad		
			)
			VALUES(
				@id 				,
				@id_APU				,
				@id_presupuesto		,
				@id_subpresupuesto	,
				@item				,
				@cantidad		
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_detalle_subpresupuesto') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_detalle_subpresupuesto >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_detalle_subpresupuesto >>>'
GO