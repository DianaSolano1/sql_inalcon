-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_perfil
IF OBJECT_ID('dbo.sp_t_cliente') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_cliente
    IF OBJECT_ID('dbo.sp_t_cliente') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_cliente >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_cliente >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_cliente
(
	@operacion		VARCHAR(5),

	@id				INT 			= NULL,
	@contrato		VARCHAR (30)    = NULL,
	@descripcion	VARCHAR (500) 	= NULL,
	@objeto			VARCHAR (300)	= NULL,
	@valor_contrato	NUMERIC (18, 2) = NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'
	BEGIN
	
		SELECT 
			id 				,
			contrato		,
			descripcion		,
			objeto			,
			valor_contrato
		FROM
			t_cliente
		WHERE
			id = 
				CASE WHEN ISNULL (@id, '') = '' THEN id 
				ELSE @id
				END
			
	--END ELSE
	--IF @operacion = 'C1'
	--BEGIN
		
	END	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				contrato		,
				descripcion		,
				objeto			,
				valor_contrato	,

				@operacion
			FROM
				t_cliente 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN			
				DELETE FROM t_cliente 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_cliente WHERE id = @id )		
		BEGIN	
				
			UPDATE t_cliente 
				SET contrato		= ISNULL (@contrato, contrato),
					descripcion		= ISNULL (@descripcion, descripcion),
					objeto			= ISNULL (@objeto, objeto),
					valor_contrato	= ISNULL (@valor_contrato, valor_contrato)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_cliente (
				contrato		,
				descripcion		,
				objeto			,
				valor_contrato	
			)
			VALUES(
				@contrato 		,
				@descripcion	,
				@objeto			,
				@valor_contrato
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_cliente') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_cliente >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_cliente >>>'
GO