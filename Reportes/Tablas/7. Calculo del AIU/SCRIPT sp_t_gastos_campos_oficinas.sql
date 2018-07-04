---------------------------------------------------------------------------
-- sp_t_gasto_campo_oficina
IF OBJECT_ID('dbo.sp_t_gasto_campo_oficina') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_gasto_campo_oficina
    IF OBJECT_ID('dbo.sp_t_gasto_campo_oficina') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_gasto_campo_oficina >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_gasto_campo_oficina >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_gasto_campo_oficina
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_AIU			INT				= NULL,
	@descripcion	VARCHAR (200)	= NULL,
	@valor			NUMERIC (19,3)	= NULL,
	@dedicacion		NUMERIC (6, 3)	= NULL,
	@tiempo_obra	NUMERIC (5, 2)	= NULL
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
			valor		,
			dedicacion	,
			tiempo_obra	
		FROM
			t_gasto_campo_oficina
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE
	
	IF @operacion = 'C2'							--> Consulta de gastos en el campo y oficinas
	BEGIN
	
		SELECT	co.id,
				co.descripcion AS 'gasto_campo_oficina',
				co.valor,
				co.dedicacion,
				co.tiempo_obra,
				dbo.TotalGastosCO(co.id) AS 'total',
				dbo.PorcentajeGastosCO(co.id) AS 'porcentaje',
				dbo.GastosCOSTIValor() AS 'GastosCOSTIValor',
				dbo.GastosCOSTIPorcentaje() AS 'GastosCOSTIPorcentaje'
		FROM t_gasto_campo_oficina co
				LEFT JOIN t_AIU aiu ON co.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		ORDER BY co.id DESC
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 			,
				id_AIU		,
				descripcion	,
				valor		,
				dedicacion	,
				tiempo_obra	,
				
				@operacion
			FROM
				t_gasto_campo_oficina 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_gasto_campo_oficina 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_gasto_campo_oficina WHERE id = @id )		
		BEGIN	
				
			UPDATE t_gasto_campo_oficina 
				SET id_AIU		= ISNULL (@id_AIU, id_AIU),
					descripcion	= ISNULL (@descripcion, descripcion),
					valor		= ISNULL (@valor, valor),
					dedicacion	= ISNULL (@dedicacion, dedicacion),
					tiempo_obra	= ISNULL (@tiempo_obra, tiempo_obra)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_gasto_campo_oficina (
				id_AIU		,
				descripcion	,
				valor		,
				dedicacion	,
				tiempo_obra
			)
			VALUES(
				@id_AIU			,
				@descripcion	,
				@valor			,
				@dedicacion		,
				@tiempo_obra
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_gasto_campo_oficina') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_gasto_campo_oficina >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_gasto_campo_oficina >>>'
GO