---------------------------------------------------------------------------
-- sp_t_presupuesto_general
IF OBJECT_ID('dbo.sp_t_presupuesto_general') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_presupuesto_general
    IF OBJECT_ID('dbo.sp_t_presupuesto_general') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_presupuesto_general >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_presupuesto_general >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_presupuesto_general
(
	@operacion		VARCHAR(5),

	@id				INT			= NULL,
	@id_APU			INT			= NULL,
	@item			INT			= NULL,
	@descripcion	VARCHAR(50)	= NULL,
	@cantidad		INT			= NULL
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
			id_APU			,	
			item			,
			descripcion		,
			cantidad
		FROM
			t_presupuesto_general
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE

	IF @operacion = 'C2'							--> Consulta del presupuesto general
	BEGIN
	
		SELECT	pg.item,
				apu.codigo,
				apu.nombre,
				u.nombre,
				dbo.TotalApuInicial(apu.codigo),
				pg.cantidad,
				dbo.ValorTotalAPULleno(apu.codigo,pg.item)
		FROM t_presupuesto_general pg
				LEFT JOIN t_apu apu ON pg.id_APU = apu.ID
				LEFT JOIN t_unidades u ON apu.id_unidad = u.id
		ORDER BY pg.item
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_APU			,
				item			,
				descripcion		,
				cantidad		,
				
				@operacion
			FROM
				t_presupuesto_general 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_presupuesto_general 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_presupuesto_general WHERE id = @id )		
		BEGIN	
				
			UPDATE t_presupuesto_general 
				SET id_APU			= ISNULL (@id_APU, id_APU),
					item			= ISNULL (@item, item),
					descripcion		= ISNULL (@descripcion, descripcion),
					cantidad		= ISNULL (@cantidad, cantidad)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_presupuesto_general (
				id 				,
				id_APU			,
				item			,
				descripcion		,
				cantidad		
			)
			VALUES(
				@id 			,
				@id_APU			,
				@item			,
				@descripcion	,
				@cantidad		
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_presupuesto_general') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_presupuesto_general >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_presupuesto_general >>>'
GO