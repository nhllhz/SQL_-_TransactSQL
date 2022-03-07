USE Ventas2

/*

EJERCICIO 1

Desarrolle una consulta que presente Artículo, Nombre, Total y TipoVenta (Mayor o Menor), y que muestre 
aquellos artículos pertenecientes a marcas activas (ACTIVO = 'S') que vendieron como mínimo $5000 en 
cualquiera de los tipos de venta en el año 2006.

Excluya siempre las ventas anuladas, y tome para el cálculo de los totales CANTIDAD * PRECIO para 
ventas minoristas, y CANTIDAD * PRECIO REAL para ventas mayoristas. 

Ordene por código de artículo y tipo de venta.

*/

SELECT
	a.articulo as Articulo,
	a.nombre as Nombre,
	sum(vd.cantidad * vd.precio) as Total,
	'Menor' as TipoVenta
from
	vencab as vc
	inner join vendet as vd
	on vc.letra = vd.letra and vc.factura = vd.factura
	inner join articulos as a
	on vd.articulo = a.articulo
	inner join marcas as m
	on a.marca = m.marca
where
	year(vc.fecha) = 2006
	and vc.anulada = 0
	and m.activo = 'S'
group by
	a.articulo,
	a.nombre
having
	sum(vd.cantidad * vd.precio) >= 5000
--
UNION ALL
--
SELECT
	a.articulo as Articulo,
	a.nombre as Nombre,
	sum(md.cantidad * md.precioreal) as Total,
	'Mayor' as TipoVenta
from
	mayorcab as mc
	inner join mayordet as md
	on mc.letra = md.letra and mc.factura = md.factura
	inner join articulos as a
	on md.articulo = a.articulo
	inner join marcas as m
	on a.marca = m.marca
where
	year(mc.fecha) = 2006
	and mc.anulada = 0
	and m.activo = 'S'
group by
	a.articulo,
	a.nombre
having
	sum(md.cantidad * md.precioreal) >= 5000
ORDER BY
	1,4

/*

EJERCICIO 2

Determine en una sola consulta qué artículos (código, nombre e importe) generaron mas ventas mayoristas
(en importe) en el año 2006 que el artículo A205221022 en el 2005. Excluya siempre las ventas anuladas.

Utilice para el cálculo de los totales CANTIDAD * PRECIOREAL.

*/

SELECT
	a.articulo AS "Artículo",
	a.nombre AS "Nombre",
	SUM(md.cantidad * md.precioreal) AS "Total"
FROM 
	articulos as a
	INNER JOIN mayordet as md ON md.articulo = a.articulo
	INNER JOIN mayorcab as mc ON (md.letra = mc.letra AND md.factura = mc.factura)
WHERE 
	YEAR(mc.fecha) = 2006 
	AND mc.anulada = 0
GROUP BY
	a.articulo,
	a.nombre
HAVING
	SUM(md.cantidad * md.precioreal) > (SELECT 
											SUM(md.cantidad * md.precioreal)
										FROM 
											mayordet as md 
											INNER JOIN mayorcab as mc 
											ON (md.letra = mc.letra AND md.factura = mc.factura)
										WHERE 
											YEAR(mc.fecha) = 2005 
											AND md.articulo = 'A205221022' 
											AND mc.anulada = 0)

/*

EJERCICIO 3

La empresa decidió pagar un premio equivalente al 3% de las ventas generadas en el año 2008 por los vendedores que
no son encargados (ENCARGADO = 'N'), están activos (ACTIVO = 'S'), y superaron los $100.000 en ventas en el año.
Además, debe cumplir la condición de haber tenido una antigüedad en el año 2008 de al menos 3 años para recibir 
el premio. Para calcular la antigüedad deberá tomar el año de la fecha de ingreso.

Liste el nombre del vendedor, su antigüedad, el total vendido en el 2008, y el valor del premio a pagar. Ordene por
vendedor y excluya ventas anuladas.

*/

SELECT
	v.nombre AS "Vendedor",
	2008 - YEAR(v.ingreso) AS "Antigüedad",
	SUM(vc.total) AS "Total Vendido",
	SUM(vc.total * 0.03) AS "Premio"
FROM
	vencab AS vc
	INNER JOIN vendedores AS v
	ON v.vendedor = vc.vendedor
WHERE
	vc.anulada = 0
	AND YEAR(vc.fecha) = 2008
	AND 2008 - YEAR(v.ingreso) >= 3
	AND v.activo = 'S'
	AND v.encargado = 'N'
GROUP BY
	v.nombre,
	2008 - YEAR(v.ingreso)
HAVING
	SUM(vc.total) > 100000
ORDER BY
	1