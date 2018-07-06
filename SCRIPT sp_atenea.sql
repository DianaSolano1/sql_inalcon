USE atenea;

GO

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_cliente
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

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_unidad
IF OBJECT_ID('dbo.sp_t_unidad') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_unidad
    IF OBJECT_ID('dbo.sp_t_unidad') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_unidad >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_unidad >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_unidad
(
	@operacion		VARCHAR(5),

	@id		INT 			= NULL,
	@nombre	VARCHAR (30)    = NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'
	BEGIN
	
		SELECT 
			id 		,
			nombre	
		FROM
			t_unidad
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 					
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 		,
				nombre	,

				@operacion
			FROM
				t_unidad 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_unidad 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_unidad WHERE id = @id )		
		BEGIN	
				
			UPDATE t_unidad 
				SET nombre	= ISNULL (@nombre, nombre)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_unidad (
				nombre		
			)
			VALUES(
				@nombre 
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_unidad') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_unidad >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_unidad >>>'
GO

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_producto
IF OBJECT_ID('dbo.sp_t_producto') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_producto
    IF OBJECT_ID('dbo.sp_t_producto') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_producto >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_producto >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_producto
(
	@operacion		VARCHAR(5),

	@id				INT 			= NULL,
	@id_unidad		INT				= NULL,
	@id_procedencia	INT				= NULL,
	@id_iva			INT				= NULL,
	@nombre			VARCHAR (30)    = NULL,
	@valor			NUMERIC (18, 2)	= NULL,
	@sn_iva			BIT				= NULL

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
			id_unidad		,
			id_procedencia	,
			id_iva			,
			nombre			,
			valor			,
			sn_iva			
		FROM
			t_producto
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	
	IF @operacion = 'C2'							--> Reporte de insumos
	BEGIN
		SELECT  
			p.nombre AS 'descripcion',
			u.nombre AS 'nombre_unidad',
			p.valor AS 'valor_directo',
			p.sn_iva,
			dbo.fc_detectar_iva(p.id) AS 'valor_total',
			pc.nombre AS 'nombre_procedencia'
		FROM	
			t_producto p
			LEFT JOIN t_unidad u ON p.id_unidad = u.id
			LEFT JOIN t_procedencia pc ON p.id_procedencia = pc.id
		ORDER BY p.nombre 
		
	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_unidad		,
				id_procedencia	,
				id_iva			,
				nombre			,
				valor			,
				sn_iva			,		

				@operacion
			FROM
				t_producto 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_producto WHERE id = @id 
				)				
					DELETE FROM t_producto 
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
	
	IF @operacion = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_producto WHERE id = @id )		
		BEGIN	
				
			UPDATE t_producto 
				SET id_unidad		= ISNULL (@id_unidad, id_unidad),
					id_procedencia	= ISNULL (@id_procedencia, id_procedencia),
					id_iva			= ISNULL (@id_iva, id_iva),
					nombre			= ISNULL (@nombre, nombre),
					valor			= ISNULL (@valor, valor),
					sn_iva			= ISNULL (@sn_iva, sn_iva)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_producto (
				id_unidad		,
				id_procedencia	,
				id_iva			,
				nombre			,
				valor			,
				sn_iva					
			)
			VALUES(
				@id_unidad		,
				@id_procedencia	,
				@id_iva			,
				@nombre			,
				@valor			,
				@sn_iva			
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_producto') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_producto >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_producto >>>'
GO

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_procedencia
IF OBJECT_ID('dbo.sp_t_procedencia') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_procedencia
    IF OBJECT_ID('dbo.sp_t_procedencia') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_procedencia >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_procedencia >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_procedencia
(
	@operacion		VARCHAR(5),

	@id		INT 			= NULL,
	@nombre	VARCHAR (30)    = NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'
	BEGIN
	
		SELECT 
			id 		,
			nombre	
		FROM
			t_procedencia
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 		,
				nombre	,

				@operacion
			FROM
				t_procedencia 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_procedencia 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_procedencia WHERE id = @id )		
		BEGIN	
				
			UPDATE t_procedencia 
				SET nombre	= ISNULL (@nombre, nombre)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_procedencia (
				nombre		
			)
			VALUES(
				@nombre 
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_procedencia') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_procedencia >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_procedencia >>>'
GO

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_legal
IF OBJECT_ID('dbo.sp_t_legal') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_legal
    IF OBJECT_ID('dbo.sp_t_legal') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_legal >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_legal >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_legal
(
	@operacion		VARCHAR(5),

	@id		INT 			= NULL,
	@nombre	VARCHAR (30)    = NULL,
	@anno	DATE 			= NULL,
	@valor	NUMERIC (18, 2)	= NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'
	BEGIN
	
		SELECT 
			id 		,
			nombre	,
			anno	,
			valor
		FROM
			t_legal
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 					
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 		,
				nombre	,
				anno	,
				valor	,

				@operacion
			FROM
				t_legal 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_legal 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_legal WHERE id = @id )		
		BEGIN	
				
			UPDATE t_legal 
				SET nombre	= ISNULL (@nombre, nombre),
					anno	= ISNULL (@anno, anno),
					valor	= ISNULL (@valor, valor)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_legal (
				nombre	,
				anno	,
				valor		
			)
			VALUES(
				@nombre ,
				@anno	,
				@valor	
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_legal') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_legal >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_legal >>>'
GO

-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_factor_subitem
IF OBJECT_ID('dbo.sp_t_factor_subitem') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_factor_subitem
    IF OBJECT_ID('dbo.sp_t_factor_subitem') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_factor_subitem >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_factor_subitem >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_factor_subitem
(
	@operacion		VARCHAR(5),

	@id				INT 			= NULL,
	@id_factor_base	INT				= NULL,
	@item			VARCHAR (5)		= NULL,
	@nombre			VARCHAR (200)   = NULL,
	@porcentaje		INT				= NULL

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
			id_factor_base	,
			item			,
			nombre			,
			porcentaje		
		FROM
			t_factor_subitem
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END

	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_factor_base	,
				item			,
				nombre			,
				porcentaje		,		

				@operacion
			FROM
				t_factor_subitem 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_factor_subitem 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_factor_subitem WHERE id = @id )		
		BEGIN	
				
			UPDATE t_factor_subitem 
				SET id_factor_base	= ISNULL (@id_factor_base, id_factor_base),
					item			= ISNULL (@item, item),
					nombre			= ISNULL (@nombre, nombre),
					porcentaje		= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_factor_subitem (
				id_factor_base	,
				item			,
				nombre			,
				porcentaje					
			)
			VALUES(
				@id_factor_base	,
				@item			,
				@nombre			,
				@porcentaje				
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_factor_subitem') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_factor_subitem >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_factor_subitem >>>'
GO


-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_factor_detalle
IF OBJECT_ID('dbo.sp_t_factor_detalle') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_factor_detalle
    IF OBJECT_ID('dbo.sp_t_factor_detalle') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_factor_detalle >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_factor_detalle >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_factor_detalle
(
	@operacion			VARCHAR(5),

	@id					INT 			= NULL,
	@id_factor_subitem	INT				= NULL,
	@nombre				VARCHAR (200)   = NULL,
	@porcentaje			INT				= NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'
	BEGIN
	
		SELECT 
			id 					,
			id_factor_subitem	,
			nombre				,
			porcentaje		
		FROM
			t_factor_detalle
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END	

	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_factor_subitem	,
				nombre				,
				porcentaje			,		

				@operacion
			FROM
				t_factor_detalle 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_factor_detalle 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_factor_detalle WHERE id = @id )		
		BEGIN	
				
			UPDATE t_factor_detalle 
				SET id_factor_subitem	= ISNULL (@id_factor_subitem, id_factor_subitem),
					nombre				= ISNULL (@nombre, nombre),
					porcentaje			= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_factor_detalle (
				id_factor_subitem	,
				nombre				,
				porcentaje					
			)
			VALUES(
				@id_factor_subitem	,
				@nombre				,
				@porcentaje				
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_factor_detalle') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_factor_detalle >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_factor_detalle >>>'
GO


-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_factor_base
IF OBJECT_ID('dbo.sp_t_factor_base') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_factor_base
    IF OBJECT_ID('dbo.sp_t_factor_base') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_factor_base >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_factor_base >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_factor_base
(
	@operacion		VARCHAR(5),

	@id				INT 			= NULL,
	@item			VARCHAR (5)		= NULL,
	@nombre			VARCHAR (200)    = NULL,
	@porcentaje		INT				= NULL

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
			item		,
			nombre		,
			porcentaje		
		FROM
			t_factor_base
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	
	
	IF @operacion = 'C2'							--> Consulta de APUS
	BEGIN
		DECLARE @T_CALCULO_FM TABLE 
		(
			item_capitulo			VARCHAR (5)		NOT NULL,
			capitulo				VARCHAR (200)	NOT NULL,
			porcentaje_capitulo		NUMERIC (5, 2)	NULL,
			item_subcapitulo		VARCHAR (5)		NULL,
			subcapitulo				VARCHAR (200)	NULL,
			porcentaje_subcapitulo	NUMERIC (5, 2)	NULL,
			item					VARCHAR (200)	NULL,
			porcentaje_item			NUMERIC (5, 2)	NULL,
			factor_multiplicador	NUMERIC(5, 2)	NULL
		)
		INSERT @T_CALCULO_FM (
			item_capitulo, 
			capitulo, 
			porcentaje_capitulo, 
			item_subcapitulo, 
			subcapitulo, 
			porcentaje_subcapitulo, 
			item, 
			porcentaje_item,
			factor_multiplicador)
		SELECT	
			b.item AS 'item_capitulo',
			b.nombre AS 'capitulo',
			b.porcentaje AS 'porcentaje_capitulo',
			s.item AS 'item_subcapitulo',
			s.nombre AS 'subcapitulo',
			s.porcentaje AS 'porcentaje_subcapitulo',
			d.nombre AS 'item',
			d.porcentaje AS 'porcentaje_item',
			dbo.fc_calcular_factor_multiplicador(b.item) as 'factor_multiplicador'
		FROM t_factor_base b
			LEFT JOIN t_factor_subitem s ON b.ID = s.id_factor_base
			LEFT JOIN t_factor_detalle d ON s.ID = d.id_factor_subitem
		ORDER BY b.item DESC

		UPDATE @T_CALCULO_FM
		SET
			porcentaje_capitulo	= dbo.fc_calcular_factor_multiplicador(item_capitulo)
		FROM
			@T_CALCULO_FM CFM
		WHERE
			porcentaje_capitulo	IS NULL

		SELECT * FROM @T_CALCULO_FM

	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 			,
				item		,
				nombre		,
				porcentaje	,		

				@operacion
			FROM
				t_factor_base 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_factor_base
				WHERE
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_factor_base WHERE id = @id )		
		BEGIN	
				
			UPDATE t_factor_base 
				SET item		= ISNULL (@item, item),
					nombre		= ISNULL (@nombre, nombre),
					porcentaje	= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_factor_base (
				item		,
				nombre		,
				porcentaje					
			)
			VALUES(
				@item		,
				@nombre		,
				@porcentaje				
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_factor_base') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_factor_base >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_factor_base >>>'
GO


-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_rango
IF OBJECT_ID('dbo.sp_t_rango') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_rango
    IF OBJECT_ID('dbo.sp_t_rango') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_rango >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_rango >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_rango
(
	@operacion		VARCHAR(5),

	@id				INT 			= NULL,
	@nombre			VARCHAR (200)   = NULL

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
			nombre	
		FROM
			t_rango
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END

	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				nombre			,
				
				@operacion
			FROM
				t_rango 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				IF NOT EXISTS(
					SELECT 1 FROM t_rango WHERE id = @id 
				)				
					DELETE FROM t_rango 
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
		IF EXISTS (SELECT 1 FROM t_rango WHERE id = @id )		
		BEGIN	
				
			UPDATE t_rango 
				SET nombre			= ISNULL (@nombre, nombre)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_rango (
				nombre					
			)
			VALUES(
				@nombre				
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_rango') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_rango >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_rango >>>'
GO


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


-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_cuadrilla_detalle
IF OBJECT_ID('dbo.sp_t_cuadrilla_detalle') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_cuadrilla_detalle
    IF OBJECT_ID('dbo.sp_t_cuadrilla_detalle') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_cuadrilla_detalle >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_cuadrilla_detalle >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_cuadrilla_detalle
(
	@operacion			VARCHAR(5),

	@id					INT				= NULL,
	@id_jornal_empleado	INT				= NULL,
	@id_cuadrilla		INT				= NULL,
	@descripcion		VARCHAR(200)	= NULL,
	@cantidad_oficial	INT				= NULL,
	@cantidad_ayudante	INT				= NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'					--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 					,
			id_jornal_empleado	,
			id_cuadrilla		,
			descripcion			,
			cantidad_oficial	,
			cantidad_ayudante
		FROM
			t_cuadrilla_detalle
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE

	IF @operacion = 'C2'					--> Consulta de cuadrillas 
	BEGIN
		DECLARE @T_CUADRILLA TABLE
		(
			id_jornal_empleado		INT				NOT NULL,
			descripcion_cuadrillas	VARCHAR (200)	NOT NULL,
			cantidad_oficial		INT				NOT NULL,
			cantidad_ayudante		INT				NOT NULL,
			valor_jornal			NUMERIC(18,2)	NULL	,
			valor_jornal_prestacion	NUMERIC(18,2)	NULL	,
			cuadrilla_h_prestacion	NUMERIC(18,2)	NULL	
		)

		INSERT @T_CUADRILLA (
			id_jornal_empleado,
			descripcion_cuadrillas,
			cantidad_oficial,
			cantidad_ayudante,
			valor_jornal)
		SELECT
			cdet.id_jornal_empleado,
			cdet.descripcion AS 'descripcion_cuadrillas',
			cdet.cantidad_oficial,
			cdet.cantidad_ayudante,
			(
				-- para el de oficial
				(cdet.cantidad_oficial * dbo.fc_obtener_valor_jornal(cdet.id_jornal_empleado,  1))
				+
				-- para el de ayudante
				(cdet.cantidad_ayudante * dbo.fc_obtener_valor_jornal(cdet.id_jornal_empleado, 0))
			) as 'valor_jornal_ayudante'

		FROM t_cuadrilla_detalle cdet
			LEFT JOIN t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
		ORDER BY cdet.descripcion DESC;
		
		UPDATE @T_CUADRILLA
		SET
			valor_jornal_prestacion	=	(valor_jornal * dbo.fc_calcular_factor_multiplicador_total())
		FROM
			@T_CUADRILLA CFM
		WHERE
			valor_jornal_prestacion	IS NULL

		UPDATE @T_CUADRILLA
		SET
			cuadrilla_h_prestacion	=	(CFM.valor_jornal_prestacion * c.horas_dia)
		FROM
			@T_CUADRILLA CFM
			LEFT JOIN t_jornal_empleado je ON CFM.id_jornal_empleado = je.id
			LEFT JOIN t_cuadrilla c ON je.id_cuadrilla = c.id
		WHERE
			cuadrilla_h_prestacion	IS NULL

		SELECT * FROM @T_CUADRILLA

	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_jornal_empleado	,
				id_cuadrilla		,
				descripcion			,
				cantidad_oficial	,
				cantidad_ayudante	,
				
				@operacion
			FROM
				t_cuadrilla_detalle 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_cuadrilla_detalle 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_cuadrilla_detalle WHERE id = @id )		
		BEGIN	
				
			UPDATE t_cuadrilla_detalle 
				SET id_jornal_empleado	= ISNULL (@id_jornal_empleado, id_jornal_empleado),
					id_cuadrilla		= ISNULL (@id_cuadrilla, id_cuadrilla),
					descripcion			= ISNULL (@descripcion, descripcion),
					cantidad_oficial	= ISNULL (@cantidad_oficial, cantidad_oficial),
					cantidad_ayudante	= ISNULL (@cantidad_ayudante, cantidad_ayudante)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_cuadrilla_detalle (
				id_jornal_empleado	,
				id_cuadrilla		,
				descripcion			,
				cantidad_oficial	,
				cantidad_ayudante	
			)
			VALUES (
				@id_jornal_empleado	,
				@id_cuadrilla		,
				@descripcion		,
				@cantidad_oficial	,
				@cantidad_ayudante
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_cuadrilla_detalle') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_cuadrilla_detalle >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_cuadrilla_detalle >>>'
GO


-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_cuadrilla
IF OBJECT_ID('dbo.sp_t_cuadrilla') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_cuadrilla
    IF OBJECT_ID('dbo.sp_t_cuadrilla') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_cuadrilla >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_cuadrilla >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_cuadrilla
(
	@operacion			VARCHAR(5),

	@id					INT = NULL,
	@id_salario_minimo	INT	= NULL,
	@dias_labor			INT = NULL,
	@horas_dia			INT = NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'						--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 					,
			id_salario_minimo	,
			dias_labor			,
			horas_dia
		FROM
			t_cuadrilla
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END

	END ELSE	

	IF @operacion = 'C2'					--> Reporte de una sola linea para la cuadrilla
	BEGIN
		SELECT	l.valor AS 'salario_minimo',
				c.dias_labor AS 'dias_laborales',
				c.horas_dia,
				dbo.fc_calcular_factor_multiplicador_total() as 'factor_prestacional'
		FROM t_cuadrilla c
		LEFT JOIN t_legal l ON c.id_salario_minimo = l.id
	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_salario_minimo	,
				dias_labor			,
				horas_dia			,
				
				@operacion
			FROM
				t_cuadrilla 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_cuadrilla 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_cuadrilla WHERE id = @id )		
		BEGIN	
				
			UPDATE t_cuadrilla 
				SET id_salario_minimo	= ISNULL (@id_salario_minimo, id_salario_minimo),
					dias_labor			= ISNULL (@dias_labor, dias_labor),
					horas_dia			= ISNULL (@horas_dia, horas_dia)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_cuadrilla (
				id_salario_minimo	,
				dias_labor			,
				horas_dia
			)
			VALUES(
				@id_salario_minimo	,
				@dias_labor			,
				@horas_dia
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_cuadrilla') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_cuadrilla >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_cuadrilla >>>'
GO


-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_apu_transporte_material
IF OBJECT_ID('dbo.sp_t_apu_transporte_material') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu_transporte_material
    IF OBJECT_ID('dbo.sp_t_apu_transporte_material') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu_transporte_material >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu_transporte_material >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu_transporte_material
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_apu			INT				= NULL,
	@id_productos	INT				= NULL,
	@distancia		NUMERIC (10, 2)	= NULL,
	@tarifa			NUMERIC (10, 2)	= NULL

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
			id_apu			,
			id_producto		,
			distancia		,
			tarifa
		FROM
			t_apu_transporte_material
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE
	
	IF @operacion = 'C2'							--> Consulta de transporte de materiales en APU
	BEGIN
	
		DECLARE @T_REPORTE_TRANSPORTE_MATERIALES TABLE 
		(
			apu						VARCHAR(5)		NOT NULL,
			transporte_materiales	VARCHAR (200)	NOT NULL,
			vol_peso_cant			VARCHAR (30)	NOT NULL,
			distancia				NUMERIC (10, 2)	NOT NULL,
			m3_km					NUMERIC (18, 2)	NOT NULL,
			tarifa					NUMERIC (10, 2)	NOT NULL,
			valor_unitario			NUMERIC (20, 2)	NOT NULL,
			total					NUMERIC (18, 2)	NULL
		)
		
		INSERT @T_REPORTE_TRANSPORTE_MATERIALES (
				apu,
				transporte_materiales,
				vol_peso_cant,
				distancia,
				m3_km,
				tarifa,
				valor_unitario)
		SELECT	
			a.codigo AS 'apu',
			p.nombre AS 'transporte_material',
			u.nombre AS 'vol_peso_cant',
			atm.distancia,
			p.valor AS 'm3_km',
			atm.tarifa,
			(p.valor * atm.tarifa) AS 'valor_unitario'
		FROM 
			t_apu_transporte_material atm
			LEFT JOIN t_producto p ON atm.id_producto = p.id
			LEFT JOIN t_unidad u ON p.id_unidad = u.id
			LEFT JOIN t_apu a ON atm.id_apu = a.ID
		ORDER BY a.codigo DESC

		UPDATE @T_REPORTE_TRANSPORTE_MATERIALES
		SET
			total	=	dbo.fc_total_transporte_material(apu)
		FROM
			@T_REPORTE_TRANSPORTE_MATERIALES RTM
		WHERE
			total	IS NULL

		SELECT * FROM @T_REPORTE_TRANSPORTE_MATERIALES

	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_apu			,
				id_producto		,
				distancia		,
				tarifa			,
				
				@operacion
			FROM
				t_apu_transporte_material 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_apu_transporte_material 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_apu_transporte_material WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu_transporte_material 
				SET id_apu			= ISNULL (@id_apu, id_apu),
					id_producto		= ISNULL (@id_productos, id_producto),
					distancia		= ISNULL (@distancia, distancia),
					tarifa			= ISNULL (@tarifa, tarifa)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu_transporte_material (
				id_apu			,
				id_producto		,
				distancia		,
				tarifa	
			)
			VALUES(
				@id_apu			,
				@id_productos	,
				@distancia		,
				@tarifa
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu_transporte_material') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu_transporte_material >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu_transporte_material >>>'
GO



-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_apu_materiales
IF OBJECT_ID('dbo.sp_t_apu_materiales') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu_materiales
    IF OBJECT_ID('dbo.sp_t_apu_materiales') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu_materiales >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu_materiales >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu_materiales
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_apu			INT				= NULL,
	@id_productos	INT				= NULL,
	@cantidad		NUMERIC (5, 2)	= NULL

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
			id_apu		,
			id_producto	,
			cantidad
		FROM
			t_apu_material
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'C2'							--> Consulta de materiales en APU
	BEGIN
	
		DECLARE @T_REPORTE_MATERIALES TABLE 
		(
			apu					VARCHAR(5)		NOT NULL,
			materiales			VARCHAR (200)	NOT NULL,
			unidad				VARCHAR (30)	NOT NULL,
			cantidad			NUMERIC (5, 2)	NOT NULL,
			valor_unitario		NUMERIC (18, 2)	NULL,
			factor_desperdicio	NUMERIC (5, 2)	NOT NULL,
			valor				NUMERIC (18, 2)	NULL,
			total				NUMERIC (18, 2)	NULL
		)
		
		INSERT @T_REPORTE_MATERIALES (
				apu,
				materiales,
				unidad,
				cantidad,
				valor_unitario,
				factor_desperdicio)
		SELECT	
			a.codigo AS 'apu',
			p.nombre AS 'materiales',
			u.nombre AS 'unidad',
			am.cantidad AS 'cantidad',
			p.valor AS 'valor_unitario',
			a.factor_desperdicio
		FROM 
			t_apu_material am
			LEFT JOIN t_producto p ON am.id_producto = p.id
			LEFT JOIN t_unidad u ON p.id_unidad = u.id
			LEFT JOIN t_apu a ON am.id_apu = a.ID
		ORDER BY a.codigo DESC

		UPDATE @T_REPORTE_MATERIALES
		SET
			valor	=	dbo.fc_calcular_valor_material(apu,p.id)
		FROM
			@T_REPORTE_MATERIALES RM
			LEFT JOIN t_producto p ON RM.materiales = p.nombre

		UPDATE @T_REPORTE_MATERIALES
		SET
			total	=	dbo.fc_total_material(apu)
		FROM
			@T_REPORTE_MATERIALES RM
			LEFT JOIN t_producto p ON RM.materiales = p.nombre
		WHERE
			total	IS NULL

		SELECT * FROM @T_REPORTE_MATERIALES
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 			,
				id_apu		,
				id_producto	,
				cantidad	,
				
				@operacion
			FROM
				t_apu_material 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_apu_material
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_apu_material WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu_material 
				SET id_apu		= ISNULL (@id_apu, id_apu),
					id_producto	= ISNULL (@id_productos, id_producto),
					cantidad	= ISNULL (@cantidad, cantidad)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu_material (
				id_apu			,
				id_producto	,
				cantidad
			)
			VALUES(
				@id_apu			,
				@id_productos	,
				@cantidad
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu_materiales') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu_materiales >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu_materiales >>>'
GO



---------------------------------------------------------------------------
-- sp_t_apu_mano_obra
IF OBJECT_ID('dbo.sp_t_apu_mano_obra') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu_mano_obra
    IF OBJECT_ID('dbo.sp_t_apu_mano_obra') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu_mano_obra >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu_mano_obra >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu_mano_obra
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_apu			INT				= NULL,
	@id_cuadrilla	INT				= NULL,
	@rendimiento	NUMERIC (5, 2)	= NULL

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
			id_apu			,
			id_cuadrilla	,
			rendimiento
		FROM
			t_apu_mano_obra
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END

	END ELSE	

	IF @operacion = 'C2'					--> Consulta de mano de obra en APU
	BEGIN
	
		DECLARE @T_REPORTE_MANO_OBRA TABLE 
		(
			apu					VARCHAR(5)		NOT NULL,
			mano_obra			VARCHAR (200)	NULL,
			jornal				NUMERIC (18, 2)	NULL,
			factor_prestacional	NUMERIC (5, 2)	NULL,
			jornal_total		NUMERIC (18, 2)	NULL,
			redimiento			NUMERIC (5, 2)	NOT NULL,
			valor				NUMERIC (18, 2) NULL,
			total				NUMERIC (18, 2)	NULL
		)
		
		INSERT @T_REPORTE_MANO_OBRA (
				apu,
				mano_obra,
				redimiento)
		SELECT	a.codigo AS 'apu',
				cd.descripcion AS 'mano_obra',
				amo.rendimiento
		FROM t_apu_mano_obra amo
				LEFT JOIN t_cuadrilla c ON amo.id_cuadrilla = c.id
				LEFT JOIN t_cuadrilla_detalle cd ON c.id = cd.id_cuadrilla
				LEFT JOIN t_apu a ON amo.id_apu = a.ID
		GROUP BY
			a.codigo		,
			cd.descripcion	,
			amo.rendimiento	
		ORDER BY a.codigo DESC

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			jornal	=	dbo.fc_mano_obra_jornal(a.codigo,cdet.id)
		FROM
			@T_REPORTE_MANO_OBRA RMO
			LEFT JOIN t_cuadrilla_detalle cdet ON RMO.mano_obra = cdet.descripcion
			left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
			left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
			left join t_apu a ON a.ID = amo.id_apu
		WHERE
			jornal	IS NULL

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			factor_prestacional	=	(dbo.fc_calcular_factor_multiplicador_total() / 100)
		FROM
			@T_REPORTE_MANO_OBRA RMO
		WHERE
			factor_prestacional	IS NULL

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			jornal_total	=	dbo.fc_mano_obra_jornal_total(a.codigo,cdet.id)
		FROM
			@T_REPORTE_MANO_OBRA RMO
			LEFT JOIN t_cuadrilla_detalle cdet ON RMO.mano_obra = cdet.descripcion
			left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
			left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
			left join t_apu a ON a.ID = amo.id_apu
		WHERE
			jornal_total	IS NULL

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			valor	=	dbo.fc_mano_obra_valor(a.codigo,cdet.id,amo.ID)
		FROM
			@T_REPORTE_MANO_OBRA RMO
			--LEFT JOIN t_productos p ON RTM.transporte_materiales = p.nombre
			LEFT JOIN t_cuadrilla_detalle cdet ON RMO.mano_obra = cdet.descripcion
			left join t_cuadrilla c ON c.id = cdet.id_cuadrilla
			left join t_apu_mano_obra amo ON amo.id_cuadrilla = c.id
			left join t_apu a ON a.ID = amo.id_apu
		WHERE
			valor	IS NULL

		UPDATE @T_REPORTE_MANO_OBRA
		SET
			total	=	dbo.fc_total_mano_obra(apu)
		FROM
			@T_REPORTE_MANO_OBRA RMO
		WHERE
			total	IS NULL

		SELECT * FROM @T_REPORTE_MANO_OBRA

	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_apu			,
				id_cuadrilla	,
				rendimiento		,
				
				@operacion
			FROM
				t_apu_mano_obra 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_apu_mano_obra 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_apu_mano_obra WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu_mano_obra 
				SET id_apu			= ISNULL (@id_apu, id_apu),
					id_cuadrilla	= ISNULL (@id_cuadrilla, id_cuadrilla),
					rendimiento		= ISNULL (@rendimiento, rendimiento)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu_mano_obra (
				id_apu			,
				id_cuadrilla	,
				rendimiento
			)
			VALUES(
				@id_apu			,
				@id_cuadrilla	,
				@rendimiento
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu_mano_obra') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu_mano_obra >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu_mano_obra >>>'
GO


-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_apu_equipo
IF OBJECT_ID('dbo.sp_t_apu_equipo') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu_equipo
    IF OBJECT_ID('dbo.sp_t_apu_equipo') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu_equipo >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu_equipo >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu_equipo
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_apu			INT				= NULL,
	@id_productos	INT				= NULL,
	@cantidad		NUMERIC (5, 2)	= NULL,
	@rendimiento	NUMERIC (5, 2)	= NULL

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
			id_apu			,
			id_producto		,
			cantidad		,
			rendimiento
		FROM
			t_apu_equipo
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END

	END ELSE	

	IF @operacion = 'C2'					--> Consulta de equipos en APU
	BEGIN
	
		DECLARE @T_REPORTE_EQUIPO TABLE 
		(
			apu			VARCHAR(5)		NOT NULL,
			equipo		VARCHAR (200)	NOT NULL,
			unidad		VARCHAR (30)	NOT NULL,
			cantidad	NUMERIC (5, 2)	NOT NULL,
			tarifa_dia	NUMERIC (18, 2)	NULL,
			rendimiento	NUMERIC (5, 2)	NOT NULL,
			valor		NUMERIC (18, 2)	NOT NULL,
			total		NUMERIC (18, 2)	NULL
		)

		INSERT @T_REPORTE_EQUIPO (
				apu,
				equipo,
				unidad,
				cantidad,
				tarifa_dia,
				rendimiento,
				valor)
		SELECT	a.codigo AS 'apu',
				p.nombre AS 'equipo',
				u.nombre AS 'unidad',
				ae.cantidad,
				p.valor AS 'tarifa_dia',
				ae.rendimiento,
				(p.valor * ae.rendimiento) AS valor
		FROM t_apu_equipo ae
				LEFT JOIN t_producto p ON ae.id_producto = p.id
				LEFT JOIN t_unidad u ON p.id_unidad = u.id
				LEFT JOIN t_apu a ON ae.id_apu = a.ID
		ORDER BY a.codigo DESC

		UPDATE @T_REPORTE_EQUIPO
		SET
			total	=	dbo.fc_total_equipo(apu)
		FROM
			@T_REPORTE_EQUIPO RE
		WHERE
			total	IS NULL

		SELECT * FROM @T_REPORTE_EQUIPO

	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_apu			,
				id_producto		,
				cantidad		,
				rendimiento		,
				
				@operacion
			FROM
				t_apu_equipo 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_apu_equipo 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_apu_equipo WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu_equipo 
				SET id_apu			= ISNULL (@id_apu, id_apu),
					id_producto		= ISNULL (@id_productos, id_producto),
					cantidad		= ISNULL (@cantidad, cantidad),
					rendimiento		= ISNULL (@rendimiento, rendimiento)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu_equipo (
				id_apu			,
				id_producto		,
				cantidad		,
				rendimiento
			)
			VALUES(
				@id_apu			,
				@id_productos	,
				@cantidad		,
				@rendimiento
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu_equipo') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu_equipo >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu_equipo >>>'
GO


-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_apu
IF OBJECT_ID('dbo.sp_t_apu') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_apu
    IF OBJECT_ID('dbo.sp_t_apu') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_apu >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_apu >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_apu
(
	@operacion			VARCHAR(5),

	@id					INT				= NULL,
	@codigo				VARCHAR(5)		= NULL,
	@nombre				VARCHAR(50)		= NULL,
	@id_unidad			INT				= NULL,
	@factor_hm			NUMERIC (6, 3)	= NULL,
	@factor_desperdicio	NUMERIC (6, 3)	= NULL,
	@sn_activa			BIT				= NULL

)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'					--> Seleccion de tabla completa o por ID
	BEGIN
	
		SELECT 
			id 					,
			codigo				,
			nombre				,
			id_unidad			,
			factor_hm			,
			factor_desperdicio	,
			sn_activa
		FROM
			t_apu
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END

	END ELSE

	IF @operacion = 'C2'					--> Consulta de APU principal
	BEGIN
		DECLARE @T_INICIAL_APU TABLE 
		(
			apu					VARCHAR(5)		NOT NULL,
			descripcion			VARCHAR(50)		NOT NULL,
			unidad				VARCHAR (30)	NOT NULL,
			factor_hm			NUMERIC (6, 3)	NOT NULL,
			factor_desperdicio	NUMERIC (6, 3)	NOT NULL,
			costos_directos		NUMERIC (18, 2)	NULL	
		)
		INSERT @T_INICIAL_APU (
				apu,
				descripcion,
				unidad,
				factor_hm,
				factor_desperdicio)
		SELECT	a.codigo AS 'apu',
				a.nombre AS 'descripcion',
				u.nombre AS 'unidad',
				a.factor_hm,
				a.factor_desperdicio
		FROM t_apu a
				LEFT JOIN t_unidad u ON a.id_unidad = u.id
		ORDER BY a.codigo DESC

		UPDATE @T_INICIAL_APU
		SET
			costos_directos	=	(
				dbo.fc_total_equipo(a.codigo)				+
				dbo.fc_total_material(a.codigo)				+
				dbo.fc_total_transporte_material(a.codigo)	+
				dbo.fc_total_mano_obra(a.codigo)
			)
		FROM
			@T_INICIAL_APU APU
			LEFT JOIN t_apu a ON a.codigo = apu.apu
			LEFT JOIN t_apu_equipo ae ON ae.id_apu = a.ID
			LEFT JOIN t_producto p ON ae.id_producto = p.id
		WHERE
			costos_directos	IS NULL

		SELECT * 
		FROM @T_INICIAL_APU apu
			LEFT JOIN t_apu a ON a.codigo = apu.apu
		WHERE
			a.ID = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END

	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				codigo				,
				nombre				,
				id_unidad			,
				factor_hm			,
				factor_desperdicio	,
				sn_activa			,
				
				@operacion
			FROM
				t_apu 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_apu 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_apu WHERE id = @id )		
		BEGIN	
				
			UPDATE t_apu 
				SET codigo				= ISNULL (@codigo, codigo),
					nombre				= ISNULL (@nombre, nombre),
					id_unidad			= ISNULL (@id_unidad, nombre),
					factor_hm			= ISNULL (@factor_hm, factor_hm),
					factor_desperdicio	= ISNULL (@factor_desperdicio, factor_desperdicio),
					sn_activa			= ISNULL (@sn_activa, sn_activa)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_apu (
				codigo				,
				nombre				,
				id_unidad			,
				factor_hm			,
				factor_desperdicio	,
				sn_activa	
			)
			VALUES(
				@codigo				,
				@nombre				,
				@id_unidad			,
				@factor_hm			,
				@factor_desperdicio	,
				@sn_activa
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_apu') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_apu >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_apu >>>'
GO


---------------------------------------------------------------------------
-- sp_t_impuestos
IF OBJECT_ID('dbo.sp_t_impuestos') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_impuestos
    IF OBJECT_ID('dbo.sp_t_impuestos') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_impuestos >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_impuestos >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_impuestos
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_AIU			INT				= NULL,
	@descripcion	VARCHAR (200)	= NULL,
	@porcentaje		NUMERIC (6, 3)	= NULL
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
			porcentaje
		FROM
			t_impuesto
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE

	IF @operacion = 'C2'							--> Consulta de impuestos
	BEGIN
	
		SELECT	i.id,
				i.descripcion AS 'impuestos',
				((i.porcentaje / 100) * c.valor_contrato) AS 'valores',
				i.porcentaje AS 'porcentaje',
				dbo.fc_impuestos_STI() AS 'ImpuestosSTI',
				dbo.fc_impuestos_total_porcentajes() AS 'ImpuestosTotalPorcentajes'
		FROM t_impuesto i
				LEFT JOIN t_AIU aiu ON i.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		ORDER BY i.id 
	
	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 			,
				id_AIU		,
				descripcion	,
				porcentaje	,
				
				@operacion
			FROM
				t_impuesto 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_impuesto
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_impuesto WHERE id = @id )		
		BEGIN	
				
			UPDATE t_impuesto
				SET id_AIU		= ISNULL (@id_AIU, id_AIU),
					descripcion	= ISNULL (@descripcion, descripcion),
					porcentaje	= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_impuesto (
				id_AIU		,
				descripcion	,
				porcentaje
			)
			VALUES(
				@id_AIU			,
				@descripcion	,
				@porcentaje
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_impuestos') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_impuestos >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_impuestos >>>'
GO


---------------------------------------------------------------------------
-- sp_t_gastos_personal
IF OBJECT_ID('dbo.sp_t_gastos_personal') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_gastos_personal
    IF OBJECT_ID('dbo.sp_t_gastos_personal') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_gastos_personal >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_gastos_personal >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_gastos_personal
(
	@operacion		VARCHAR(5),

	@id						INT				= NULL,
	@id_AIU					INT				= NULL,
	@id_empleado			INT				= NULL,
	@cantidad_empleado		INT				= NULL,
	@factor_prestacional	NUMERIC (5, 2)	= NULL,
	@valor					NUMERIC (20, 2)	= NULL,
	@dedicacion				NUMERIC (6, 3)	= NULL,
	@tiempo_obra			NUMERIC (5, 2)	= NULL
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
			id_AIU				,
			id_empleado			,
			cantidad_empleado	,
			factor_prestacional	,
			valor				,
			dedicacion			,
			tiempo_obra
		FROM
			t_gasto_personal
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'C2'							--> Consulta gastos de personal
	BEGIN
	
		SELECT	gp.id,
				cs.nombre AS 'gastos_personal',
				gp.cantidad_empleado AS 'cantidad',
				gp.factor_prestacional,
				gp.valor,
				gp.dedicacion,
				gp.tiempo_obra,
				dbo.fc_gastos_P_total(gp.id) AS 'total',
				dbo.fc_gastos_P_porcentaje(gp.id) AS 'porcentaje',
				dbo.fc_gastos_PSTI() AS 'GastosPSTI',
				dbo.fc_gastos_P_total_porcentaje() AS 'GastosPTotalPorcentaje'
		FROM t_gasto_personal gp
				LEFT JOIN t_cargo_sueldo cs ON gp.id_empleado = cs.id
				LEFT JOIN t_AIU aiu ON gp.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		ORDER BY gp.id 
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_AIU				,
				id_empleado			,
				cantidad_empleado	,
				factor_prestacional	,
				valor				,
				dedicacion			,
				tiempo_obra			,
				
				@operacion
			FROM
				t_gasto_personal 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_gasto_personal 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_gasto_personal WHERE id = @id )		
		BEGIN	
				
			UPDATE t_gasto_personal 
				SET id_AIU				= ISNULL (@id_AIU, id_AIU),
					id_empleado			= ISNULL (@id_empleado, id_empleado),
					cantidad_empleado	= ISNULL (@cantidad_empleado, cantidad_empleado),
					factor_prestacional	= ISNULL (@factor_prestacional, factor_prestacional),
					valor				= ISNULL (@valor, valor),
					dedicacion			= ISNULL (@dedicacion, dedicacion),
					tiempo_obra			= ISNULL (@tiempo_obra, tiempo_obra)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_gasto_personal (
				id_AIU				,
				id_empleado			,
				cantidad_empleado	,
				factor_prestacional	,
				valor				,
				dedicacion			
			)
			VALUES(
				@id_AIU					,
				@id_empleado			,
				@cantidad_empleado		,
				@factor_prestacional	,
				@valor					,
				@dedicacion
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_gastos_personal') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_gastos_personal >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_gastos_personal >>>'
GO


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
				dbo.fc_gastos_l_porcentaje(gl.id) AS 'porcentaje',
				dbo.fc_gastos_LSTI_valores() as 'GastosLSTIValores',
				dbo.fc_gastos_LSTI_porcentaje() as 'GastosLSTIPorcentajes'
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
				dbo.fc_total_gastos_CO(co.id) AS 'total',
				dbo.fc_porcentaje_gastos_CO(co.id) AS 'porcentaje',
				dbo.fc_gastos_COSTI_valor() AS 'GastosCOSTIValor',
				dbo.fc_gastos_COSTI_porcentaje() AS 'GastosCOSTIPorcentaje'
		FROM t_gasto_campo_oficina co
				LEFT JOIN t_AIU aiu ON co.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		ORDER BY co.id
	
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
		ORDER BY c.valor_contrato
	
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


---------------------------------------------------------------------------
-- sp_t_admin_imprevisto
IF OBJECT_ID('dbo.sp_t_admin_imprevisto') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_admin_imprevisto
    IF OBJECT_ID('dbo.sp_t_admin_imprevisto') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_admin_imprevisto >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_admin_imprevisto >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_admin_imprevisto
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@id_AIU			INT				= NULL,
	@descripcion	VARCHAR (200)	= NULL,
	@porcentaje		NUMERIC (6, 3)	= NULL,
	@sn_administra	NUMERIC (19,2)	= NULL
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
			id_AIU			,
			descripcion		,
			sn_administra	,
			porcentaje
		FROM
			t_admin_imprevisto
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'C2'							--> Consulta ADMINISTRACION IMPREVISTOS Y UTILIDADES
	BEGIN
	
		DECLARE @T_ADMIN_IMPREVISTOS_UTIL TABLE 
		(
			id								INT				NOT NULL,
			admin_imprevistos_utilidades	VARCHAR (200)	NOT NULL,
			valores							NUMERIC (18, 2)	NULL,
			porcentaje						NUMERIC (6, 3)	NULL,
			valor_total						NUMERIC(18, 2)	NULL,
			porcentaje_total				NUMERIC(5, 2)	NULL
		)

		INSERT @T_ADMIN_IMPREVISTOS_UTIL (
				id,
				admin_imprevistos_utilidades,
				valores,
				porcentaje
			)
		SELECT	ai.id,
				ai.descripcion AS 'admision_imprevistos_utilidades',
				(c.valor_contrato * (ai.porcentaje / 100)) AS 'valores',
				ai.porcentaje AS 'porcentaje'
		FROM t_admin_imprevisto ai
				LEFT JOIN t_AIU aiu ON ai.id_AIU = aiu.id
				LEFT JOIN t_cliente c ON aiu.id_cliente = c.ID
		ORDER BY ai.id DESC

		UPDATE @T_ADMIN_IMPREVISTOS_UTIL
		SET
			valores	=	(dbo.fc_valor_admin())
		FROM
			@T_ADMIN_IMPREVISTOS_UTIL ADM
		WHERE
			valores	IS NULL

		UPDATE @T_ADMIN_IMPREVISTOS_UTIL
		SET
			porcentaje	=	(dbo.fc_porcentaje_admin())
		FROM
			@T_ADMIN_IMPREVISTOS_UTIL ADM
		WHERE
			porcentaje	IS NULL

		UPDATE @T_ADMIN_IMPREVISTOS_UTIL
		SET
			valor_total			= (dbo.fc_total_AIU_valor())
		FROM
			@T_ADMIN_IMPREVISTOS_UTIL ADM
		WHERE
			valor_total	IS NULL

		UPDATE @T_ADMIN_IMPREVISTOS_UTIL
		SET
			porcentaje_total	= (dbo.fc_total_AIU_porcentaje())
		FROM
			@T_ADMIN_IMPREVISTOS_UTIL ADM
		WHERE
			porcentaje_total	IS NULL

		SELECT * FROM @T_ADMIN_IMPREVISTOS_UTIL
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_AIU			,
				descripcion		,
				sn_administra	,
				porcentaje		,
				
				@operacion
			FROM
				t_admin_imprevisto
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_admin_imprevisto
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_admin_imprevisto WHERE id = @id )		
		BEGIN	
				
			UPDATE t_admin_imprevisto
				SET id_AIU			= ISNULL (@id_AIU, id_AIU),
					descripcion		= ISNULL (@descripcion, descripcion),
					sn_administra	= ISNULL (@sn_administra, sn_administra),
					porcentaje		= ISNULL (@porcentaje, porcentaje)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_admin_imprevisto (
				id_AIU			,
				descripcion		,
				sn_administra	,
				porcentaje
			)
			VALUES(
				@id_AIU			,
				@descripcion	,
				@sn_administra	,
				@porcentaje
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_admin_imprevisto') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_admin_imprevisto >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_admin_imprevisto >>>'
GO


---------------------------------------------------------------------------
-- sp_t_rol_cargo
IF OBJECT_ID('dbo.sp_t_rol_cargo') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_rol_cargo
    IF OBJECT_ID('dbo.sp_t_rol_cargo') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_rol_cargo >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_rol_cargo >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_rol_cargo
(
	@operacion		VARCHAR(5),

	@id				INT				= NULL,
	@nombre			VARCHAR (200)	= NULL
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
			nombre	
		FROM
			t_rol_cargo
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 		,
				nombre	,
				
				@operacion
			FROM
				t_rol_cargo 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_rol_cargo 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_rol_cargo WHERE id = @id )		
		BEGIN	
				
			UPDATE t_rol_cargo 
				SET nombre		= ISNULL (@nombre, nombre)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_rol_cargo (
				nombre
			)
			VALUES(
				@nombre
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_rol_cargo') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_rol_cargo >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_rol_cargo >>>'
GO


---------------------------------------------------------------------------
-- sp_t_experiencia
IF OBJECT_ID('dbo.sp_t_experiencia') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_experiencia
    IF OBJECT_ID('dbo.sp_t_experiencia') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_experiencia >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_experiencia >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_experiencia
(
	@operacion		VARCHAR(5),

	@id			INT				= NULL,
	@nombre		VARCHAR (100)	= NULL
)
WITH ENCRYPTION

AS
	SET DATEFORMAT dmy;
	SET NOCOUNT ON ;

	SET @operacion = UPPER(@operacion);
	
	IF @operacion = 'C1'
	BEGIN
	
		SELECT 
			id 		,
			nombre	
		FROM
			t_experiencia
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 		,
				nombre	,
				
				@operacion
			FROM
				t_experiencia 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_experiencia 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_experiencia WHERE id = @id )		
		BEGIN	
				
			UPDATE t_experiencia 
				SET nombre	= ISNULL (@nombre, nombre)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_experiencia (
				nombre
			)
			VALUES(
				@nombre
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_experiencia') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_experiencia >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_experiencia >>>'
GO


---------------------------------------------------------------------------
-- sp_t_costos_personal
IF OBJECT_ID('dbo.sp_t_costos_personal') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_costos_personal
    IF OBJECT_ID('dbo.sp_t_costos_personal') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_costos_personal >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_costos_personal >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_costos_personal
(
	@operacion			VARCHAR(5),

	@id					INT				= NULL,
	@id_experiencia		INT				= NULL,
	@id_cargo			INT				= NULL,
	@cantidad			INT				= NULL,
	@dedicacion			NUMERIC (6, 3)	= NULL,
	@tiempo_ejecucion	INT				= NULL
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
			id_experiencia	,
			id_cargo		,
			cantidad		,
			dedicacion		,
			tiempo_ejecucion
		FROM
			t_costo_personal
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'C2'							--> Consulta costos personal
	BEGIN
	
		SELECT	
			rc.nombre AS 'rol',
			cs.nombre AS 'cargo',
			cp.cantidad,
			ex.nombre AS 'experiencia_general_específica',
			cp.dedicacion,
			cp.tiempo_ejecucion,
			cs.sueldo_basico,
			dbo.fc_costo_personal_parcial(cs.ID) AS 'costo_parcial'
		FROM 
			t_costo_personal cp
			LEFT JOIN t_experiencia ex ON cp.id_experiencia = ex.ID
			LEFT JOIN t_cargo_sueldo cs ON cp.id_experiencia = cs.ID
			LEFT JOIN t_rol_cargo rc ON cs.id_rol = rc.ID
		ORDER BY rc.nombre 
	
	END ELSE

	IF @operacion = 'C3'							--> Consulta el resultado final de los costos personal
	BEGIN

		DECLARE @T_TOTAL_COSTOS_PERSONAL TABLE 
		(
			sub_total		NUMERIC (18, 2)	NOT NULL,
			FM				NUMERIC (5, 2)	NOT NULL,
			total_personal	NUMERIC (18, 2)	NULL
		)

		INSERT @T_TOTAL_COSTOS_PERSONAL (
				sub_total,
				FM
			)
		SELECT	(dbo.fc_costo_personal_subtotal()),
				2

		UPDATE @T_TOTAL_COSTOS_PERSONAL
		SET
			total_personal			= (dbo.fc_total_personal())
		FROM
			@T_TOTAL_COSTOS_PERSONAL ADM
		WHERE
			total_personal	IS NULL

		SELECT * FROM @T_TOTAL_COSTOS_PERSONAL

	END ELSE

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_experiencia		,
				id_cargo			,
				cantidad			,
				dedicacion			,
				tiempo_ejecucion	,
				
				@operacion
			FROM
				t_costo_personal 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_costo_personal 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_costo_personal WHERE id = @id )		
		BEGIN	
				
			UPDATE t_costo_personal 
				SET id_experiencia		= ISNULL (@id_experiencia, id_experiencia),
					id_cargo			= ISNULL (@id_cargo, id_cargo),
					cantidad			= ISNULL (@cantidad, cantidad),
					dedicacion			= ISNULL (@dedicacion, dedicacion),
					tiempo_ejecucion	= ISNULL (@tiempo_ejecucion, tiempo_ejecucion)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_costo_personal (
				id 					,
				id_experiencia		,
				id_cargo			,
				cantidad			,
				dedicacion			,
				tiempo_ejecucion
			)
			VALUES(
				@id 				,
				@id_experiencia		,
				@id_cargo			,
				@cantidad			,
				@dedicacion			,
				@tiempo_ejecucion
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_costos_personal') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_costos_personal >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_costos_personal >>>'
GO


---------------------------------------------------------------------------
-- sp_t_costo_directo
IF OBJECT_ID('dbo.sp_t_costo_directo') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_costo_directo
    IF OBJECT_ID('dbo.sp_t_costo_directo') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_costo_directo >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_costo_directo >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_costo_directo
(
	@operacion	VARCHAR(5),

	@id					INT				= NULL,
	@id_unidad			INT				= NULL,
	@nombre				VARCHAR (200)	= NULL,
	@cantidad			INT				= NULL,
	@dedicacion			NUMERIC (6, 3)	= NULL,
	@tiempo_ejecucion	INT				= NULL,
	@tarifa				NUMERIC (18,2)	= NULL
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
			id_unidad			,
			nombre				,
			cantidad			,
			dedicacion			,
			tiempo_ejecucion	,
			tarifa
		FROM
			t_costo_directo
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE
	
	IF @operacion = 'C2'							--> Consulta de otros costos directos
	BEGIN
	
		SELECT	cd.nombre AS 'descripcion',
				cd.cantidad,
				u.nombre AS 'unidad',
				cd.dedicacion,
				cd.tiempo_ejecucion,
				cd.tarifa,
				dbo.fc_costo_directo_parcial(cd.id) AS 'costo_parcial',
				dbo.fc_costo_directo_parcial_total() AS CostoDirectoParcialTotal
		FROM t_costo_directo cd
				LEFT JOIN t_unidad u ON cd.id_unidad = u.id
		ORDER BY cd.nombre
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 					,
				id_unidad			,
				nombre				,
				cantidad			,
				dedicacion			,
				tiempo_ejecucion	,
				tarifa				,
				
				@operacion
			FROM
				t_costo_directo 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_costo_directo 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_costo_directo WHERE id = @id )		
		BEGIN	
				
			UPDATE t_costo_directo 
				SET id_unidad			= ISNULL (@id_unidad, id_unidad),
					nombre				= ISNULL (@nombre, nombre),
					cantidad			= ISNULL (@cantidad, cantidad),
					dedicacion			= ISNULL (@dedicacion, dedicacion),
					tiempo_ejecucion	= ISNULL (@tiempo_ejecucion, tiempo_ejecucion),
					tarifa				= ISNULL (@tarifa, tarifa)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_costo_directo (
				id_unidad			,
				nombre				,
				cantidad			,
				dedicacion			,
				tiempo_ejecucion	,
				tarifa	
			)
			VALUES(
				@id_unidad			,
				@nombre				,
				@cantidad			,
				@dedicacion			,
				@tiempo_ejecucion	,
				@tarifa
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_costo_directo') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_costo_directo >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_costo_directo >>>'
GO


---------------------------------------------------------------------------
-- sp_t_cargo_sueldo
IF OBJECT_ID('dbo.sp_t_cargo_sueldo') IS NOT NULL
BEGIN
    DROP PROCEDURE dbo.sp_t_cargo_sueldo
    IF OBJECT_ID('dbo.sp_t_cargo_sueldo') IS NOT NULL
        PRINT '<<< FAILED DROPPING PROCEDURE dbo.sp_t_cargo_sueldo >>>'
    ELSE
        PRINT '<<< DROPPED PROCEDURE dbo.sp_t_cargo_sueldo >>>'
END
GO

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO


CREATE PROCEDURE sp_t_cargo_sueldo
(
	@operacion	VARCHAR(5),

	@id				INT				= NULL,
	@id_rol			INT				= NULL,
	@nombre			VARCHAR (200)	= NULL,
	@sueldo_basico	NUMERIC (18,2)	= NULL
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
			id_rol			,
			nombre			,
			sueldo_basico
		FROM
			t_cargo_sueldo
		WHERE
			id = 
				CASE 
					WHEN ISNULL (@id, '') = '' THEN id 
					ELSE @id
				END
	
	END ELSE	

	IF @operacion = 'B' OR @operacion = 'A'
	BEGIN
		BEGIN TRAN
			SELECT 
				id 				,
				id_rol			,
				nombre			,
				sueldo_basico	,
				
				@operacion
			FROM
				t_cargo_sueldo 
			WHERE 
				id = @id
			
			IF @operacion = 'B'
			BEGIN
				DELETE FROM t_cargo_sueldo 
				WHERE 
					id = @ID
			END 

			COMMIT TRAN
	END 
	
	IF @OPERACION = 'I' OR @operacion = 'A'
	BEGIN
		IF EXISTS (SELECT 1 FROM t_cargo_sueldo WHERE id = @id )		
		BEGIN	
				
			UPDATE t_cargo_sueldo 
				SET id_rol			= ISNULL (@id_rol, id_rol),
					nombre			= ISNULL (@nombre, nombre),
					sueldo_basico	= ISNULL (@sueldo_basico, sueldo_basico)
			WHERE 
				id = @id
		END ELSE
		BEGIN
			INSERT INTO t_cargo_sueldo (
				id_rol			,
				nombre			,
				sueldo_basico	
			)
			VALUES(
				@id_rol			,
				@nombre			,
				@sueldo_basico
			)
		END
	END
GO

IF OBJECT_ID('dbo.sp_t_cargo_sueldo') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_t_cargo_sueldo >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_t_cargo_sueldo >>>'
GO


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
		SELECT	dbo.fc_total_costos_interventoria() AS Total_Costos_Interventoria,
				dbo.fc_total_costos_mas_iva() AS Total_Costos_De_Iva,
				dbo.fc_total_costos() AS Total_Costos

		SELECT * FROM @T_SUPERVISION_INTERVENTORIA
	
	END
GO

IF OBJECT_ID('dbo.sp_costos_interventoria') IS NOT NULL
    PRINT '<<< CREATED PROCEDURE dbo.sp_costos_interventoria >>>'
ELSE
    PRINT '<<< FAILED CREATING PROCEDURE dbo.sp_costos_interventoria >>>'
GO


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
			dbo.fc_total_apu_inicial(apu.codigo) AS TotalApuInicial,
			s.cantidad,
			dbo.fc_valor_total_SUBAPU_lleno(apu.codigo,s.item) AS ValorTotalSUBAPULleno
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
				dbo.fc_total_apu_inicial(apu.codigo) AS TotalApuInicial,
				pg.cantidad,
				dbo.fc_valor_total_APU_lleno(apu.codigo,pg.item) AS ValorTotalAPULleno
		FROM t_presupuesto_general pg
				LEFT JOIN t_apu apu ON pg.id_APU = apu.ID
				LEFT JOIN t_unidad u ON apu.id_unidad = u.id
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
				dbo.fc_total_apu_inicial(apu.codigo) AS TotalApuInicial,
				ds.cantidad,
				dbo.fc_valor_total_DETAPU_lleno(apu.codigo,ds.item) AS ValorTotalDETAPULleno
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