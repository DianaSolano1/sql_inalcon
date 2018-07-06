---------------------------------------------------------------------------
-- sp_t_gastos_legales
IF OBJECT_ID('dbo.sp_t_gastos_legales') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_gastos_legales
    IF OBJECT_ID('dbo.sp_t_gastos_legales') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_gastos_legales >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_gastos_legales >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_gastos_legales
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_AIU			INT				= NULL,
	@descripcion	VARCHAR (200)	= NULL,
	@porcentaje		NUMERIC (6, 3)	= NULL,
	@valores		NUMERIC (19,2)	= NULL
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
			valores		,
			porcentaje
		FROM
			t_gasto_legal
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE
	
	IF @operacion = 'C2'							--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT	gl.id,
				gl.descripcion AS 'gastos_legales',
				gl.valores,
				dbo.GastosLPorcentaje(gl.id) AS 'porcentaje',
				dbo.GastosLSTIValores() as 'GastosLSTIValores',
				dbo.GastosLSTIPorcentajes() as 'GastosLSTIPorcentajes'
		FROM t_gasto_legal gl
				LEFT JOIN t_AIU a ON gl.id_AIU = a.id
				LEFT JOIN t_cliente cl ON a.id_cliente = cl.ID
		ORDER BY gl.id
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 			,
				id_AIU		,
				descripcion	,
				valores		,
				porcentaje	,
				
				@operacion
			FROM
				t_gasto_legal 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_gasto_legal 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_gasto_legal WHERE id = @id )		
		BEGIN	
				
			UPDATE t_gasto_legal
				SET id_AIU		= ISNULL (@id_AIU, id_AIU),
					descripcion	= ISNULL (@descripcion, descripcion),
					valores		= ISNULL (@valores, valores),
					porcentaje	= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_gasto_legal (
				id_AIU		,
				descripcion	,
				valores		,
				porcentaje
			)
			VALUES(
				@id_AIU			,
				@descripcion	,
				@valores		,
				@porcentaje
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_gastos_legales') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_gastos_legales >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_gastos_legales >>>'
GO