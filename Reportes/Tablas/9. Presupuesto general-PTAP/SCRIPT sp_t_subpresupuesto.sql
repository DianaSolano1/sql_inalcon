---------------------------------------------------------------------------
-- sp_t_subpresupuesto
IF OBJECT_ID('dbo.sp_t_subpresupuesto') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_subpresupuesto
    IF OBJECT_ID('dbo.sp_t_subpresupuesto') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_subpresupuesto >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_subpresupuesto >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_subpresupuesto
(
	@operacion		VARCHAR(5),

	@id				INT			= NULL,
	@id_APU			INT			= NULL,
	@id_presupuesto	INT			= NULL,
	@item			INT			= NULL,
	@descripcion	INT			= NULL,
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
			id_presupuesto	,	
			item			,
			descripcion		,
			cantidad
		FROM
			t_subpresupuesto
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE

	IF @operacion = 'C2'							--> Consulta el subpresupuesto
	BEGIN
	
		SELECT	
			pg.item,
			s.item,
			apu.codigo,
			apu.nombre,
			u.nombre,
			dbo.TotalApuInicial(apu.codigo) AS TotalApuInicial,
			s.cantidad,
			dbo.ValorTotalSUBAPULleno(apu.codigo,s.item) AS ValorTotalSUBAPULleno
		FROM 
			t_subpresupuesto s
			LEFT JOIN t_presupuesto_general pg ON s.id_presupuesto = pg.id
			LEFT JOIN t_apu apu ON s.id_APU = apu.ID
			LEFT JOIN t_unidad u ON apu.id_unidad = u.id
		ORDER BY pg.item
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_APU			,
				id_presupuesto	,
				item			,
				descripcion		,
				cantidad		,
				
				@operacion
			FROM
				t_subpresupuesto 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_subpresupuesto WHERE id = @id 
				)				
					DELETE FROM t_subpresupuesto 
					WHERE 
						id = @ID
				ELSE
					BEGIN
						ROLLBACK TRAN
						
						RETURN;
					END
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_subpresupuesto WHERE id = @id )		
		BEGIN	
				
			UPDATE t_subpresupuesto 
				SET id_APU			= ISNULL (@id_APU, id_APU),
					id_presupuesto	= ISNULL (@id_presupuesto, id_presupuesto),
					item			= ISNULL (@item, item),
					descripcion		= ISNULL (@descripcion, descripcion),
					cantidad		= ISNULL (@cantidad, cantidad)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_subpresupuesto (
				id 				,
				id_APU			,
				id_presupuesto	,
				item			,
				descripcion		,
				cantidad		
			)
			VALUES(
				@id 			,
				@id_APU			,
				@id_presupuesto	,
				@item			,
				@descripcion	,
				@cantidad		
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_subpresupuesto') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_subpresupuesto >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_subpresupuesto >>>'
GO