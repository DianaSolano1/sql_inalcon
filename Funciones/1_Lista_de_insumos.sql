CREATE FUNCTION fc_detectarIva(@id_producto BIGINT)
RETURNS BIGINT -- aqui pones el tipo de dato que retorna
AS BEGIN
   
   DECLARE @tieneIva BIT
   DECLARE @valorIva NUMERIC(18, 2)
   DECLARE @precioARetornar NUMERIC(18, 2)
   DECLARE @precioNormal NUMERIC(18, 2)

   SET @precioNormal = (SELECT valor 
						FROM t_productos 
						WHERE id = @id_producto)
   SET @tieneIva = (SELECT sn_iva 
					FROM t_productos 
					WHERE id = @id_producto)
   SET @valorIva = (SELECT (1 + (l.valor / 100)) AS 'valor_total'
					FROM t_productos p
					LEFT JOIN t_legal l ON p.id_iva = l.id
					WHERE p.id = @id_producto)

   IF @tieneIva = 1							--> Si
   BEGIN
       SET @precioARetornar =   @precioNormal * @valorIva
   END
   ELSE
   BEGIN									--> No
       SET @precioARetornar = @precioNormal
   END 

   RETURN @precioARetornar
END

go


SELECT nombre, sn_iva, valor, dbo.fc_detectarIva(id) AS precio FROM t_productos