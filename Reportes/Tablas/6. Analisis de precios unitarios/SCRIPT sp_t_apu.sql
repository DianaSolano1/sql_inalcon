-------------------------------------------------------------------------------------------------------------------------------------------------------
-- sp_t_perfil
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
				dbo.TotalEquipo(a.codigo)				+
				dbo.TotalMaterial(a.codigo)				+
				dbo.TotalTransporteMaterial(a.codigo)	+
				dbo.TotalManoObra(a.codigo)
			)
		FROM
			@T_INICIAL_APU APU
			LEFT JOIN t_apu a ON a.codigo = apu.apu
			LEFT JOIN t_apu_equipo ae ON ae.id_apu = a.ID
			LEFT JOIN t_producto p ON ae.id_productos = p.id
		WHERE
			costos_directos	IS NULL

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