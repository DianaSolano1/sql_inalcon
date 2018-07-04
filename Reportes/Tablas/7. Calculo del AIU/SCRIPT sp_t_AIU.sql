---------------------------------------------------------------------------
-- sp_t_AIU
IF OBJECT_ID('dbo.sp_t_AIU') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_AIU
    IF OBJECT_ID('dbo.sp_t_AIU') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_AIU >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_AIU >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_AIU
(
	@operacion		VARCHAR(5),

	@id			INT				= NULL,
	@id_cliente	INT				= NULL

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
			id_cliente
		FROM
			t_AIU
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'C2'							--> Consulta el valor directo del prouecto
	BEGIN
	
		SELECT
			c.valor_contrato AS 'valor_directo_proyecto'
		FROM 
			t_AIU a
			LEFT JOIN t_cliente c ON a.id_cliente = c.ID
		ORDER BY c.valor_contrato DESC
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 			,
				id_cliente	,
				
				@operacion
			FROM
				t_AIU 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_AIU 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_AIU WHERE id = @id )		
		BEGIN	
				
			UPDATE t_AIU 
				SET id_cliente	= ISNULL (@id_cliente, id_cliente)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_AIU (
				id_cliente
			)
			VALUES(
				@id_cliente
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_AIU') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_AIU >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_AIU >>>'
GO