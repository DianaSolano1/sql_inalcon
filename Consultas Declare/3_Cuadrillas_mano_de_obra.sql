DECLARE @T_CUADRILLAS TABLE
		(
			id_jornal_empleado		INT				NOT NULL,
			descripcion_cuadrillas	VARCHAR (200)	NOT NULL,
			cantidad_oficial		INT				NOT NULL,
			cantidad_ayudante		INT				NOT NULL,
      valor_jornal        int NULL
		)

INSERT @T_CUADRILLAS (
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
      (cdet.cantidad_oficial * dbo.ObtenerValorJornal(cdet.id_jornal_empleado,  1))

      +
      -- para el de ayudante
      (cdet.cantidad_ayudante * dbo.ObtenerValorJornal(cdet.id_jornal_empleado, 0))

    )

      as 'valor_jornal_ayudante'
  FROM t_cuadrilla_detalle cdet
    LEFT JOIN t_jornal_empleado je ON cdet.id_jornal_empleado = je.id
  GROUP BY
    cdet.id_jornal_empleado,
    cdet.descripcion,
    cdet.cantidad_oficial,
    cdet.cantidad_ayudante
  HAVING COUNT(*) >= 1
  ORDER BY cdet.descripcion DESC;


		SELECT * FROM @T_CUADRILLAS