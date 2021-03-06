-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_jornal_empleado
IF OBJECT_ID('dbo.sp_t_jornal_empleado') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_jornal_empleado
    IF OBJECT_ID('dbo.sp_t_jornal_empleado') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_jornal_empleado >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_jornal_empleado >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_jornal_empleado
(
	@operacion		VARCHAR(5),

	@id				INT 			= NULL,
	@id_cuadrilla	INT				= NULL,
	@id_rango		INT				= NULL,
	@descripcion	VARCHAR (200)   = NULL,
	@sn_ayudante	BIT				= NULL,
	@porcentaje		NUMERIC (6, 2)	= NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'					--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 				,
			id_cuadrilla	,
			id_rango		,
			descripcion		,
			sn_ayudante		,
			porcentaje
		FROM
			t_jornal_empleado
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END

	END ELSE	
		
	IF @operacion = 'C2'					--> Consulta de jornales
	BEGIN
		SELECT	
			je.descripcion,
			je.porcentaje,
			cl.valor AS 'salario_minimo',
			cd.dias_labor AS 'dias_laborales',
			((1 + (je.porcentaje / 100)) * (cl.valor / cd.dias_labor)) AS 'valor_jornal',
			je.sn_ayudante AS 'cargo'
		FROM 
			t_jornal_empleado je
			LEFT JOIN t_cuadrilla cd ON je.id_cuadrilla = cd.id
			LEFT JOIN t_legal cl ON cd.id_salario_minimo = cl.id
	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_cuadrilla	,
				id_rango		,
				descripcion		,
				sn_ayudante		,
				porcentaje		,
				
				@operacion
			FROM
				t_jornal_empleado 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_jornal_empleado 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_jornal_empleado WHERE id = @id )		
		BEGIN	
				
			UPDATE t_jornal_empleado 
				SET id_cuadrilla	= ISNULL (@id_cuadrilla, id_cuadrilla),
					id_rango		= ISNULL (@id_rango, id_rango),
					descripcion		= ISNULL (@descripcion, descripcion),
					sn_ayudante		= ISNULL (@sn_ayudante, sn_ayudante),
					porcentaje		= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_jornal_empleado (
				id_cuadrilla	,
				id_rango		,
				descripcion		,
				sn_ayudante		,
				porcentaje
			)
			VALUES(
				@id_cuadrilla	,
				@id_rango		,
				@descripcion	,
				@sn_ayudante	,
				@porcentaje
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_jornal_empleado') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_jornal_empleado >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_jornal_empleado >>>'
GO