USE Ventas2

/*

Listar la cantidad que se vendió de cada artículo (tanto mayorista como minorista) en el año 2007. Excluir ventas anuladas.

Presentar código de artículo, nombre y cantidad total vendida.

Ordenar por código de artículo.

*/

SELECT
	vart.CODIGO,
	vart.ARTICULO,
	SUM(vart.TOTAL) AS "TOTAL"
FROM
	(SELECT
		a.articulo AS "CODIGO",
		a.nombre AS "ARTICULO",
		SUM(vd.cantidad) AS "TOTAL"
	FROM
		vencab AS vc
		INNER JOIN vendet AS vd
		ON vc.letra = vd.letra AND vc.factura = vd.factura
		INNER JOIN articulos AS a
		ON vd.articulo = a.articulo
	WHERE
		vc.anulada = 0
		AND vc.fecha BETWEEN '2007-01-01' AND '2007-12-31'
	GROUP BY
		a.articulo,
		a.nombre
	--
	UNION ALL
	--
	SELECT
		a.articulo AS "CODIGO",
		a.nombre AS "ARTICULO",
		SUM(md.cantidad) AS "TOTAL"
	FROM
		mayorcab AS mc
		INNER JOIN mayordet AS md
		ON mc.letra = md.letra AND mc.factura = md.factura
		INNER JOIN articulos AS a
		ON md.articulo = a.articulo
	WHERE
		mc.anulada = 0
		AND mc.fecha BETWEEN '2007-01-01' AND '2007-12-31'
	GROUP BY
		a.articulo,
		a.nombre) AS vart
GROUP BY
	vart.CODIGO,
	vart.ARTICULO
ORDER BY
	1


SELECT
	x.nombre,
	x.preciomenor
FROM
	(SELECT * FROM articulos) AS x

/*

ventas minoristas (1)
A          1
A          3
A          7

A          11


ventas mayoristas (2)
A         100
A          55
A          20


A         175

UNION DE (1) Y (2)

A         11
A        175

A        186

*/

/*

EJERCICIO 1

Mostrar para el año 2006 la distribución de ventas (cantidades) por rubro. Discriminar mes a mes la cantidad
vendida por cada rubro. Listar mes, nombre rubro y cantidad. Ordenar por mes y cantidades vendidas de mayor a menor.
Excluir ventas anuladas.

TABLAS:
VENCAB (letra y factura)
VENDET (letra y factura) (articulo)
ARTICULOS (articulo) (rubro)
RUBROS (rubro)

*/

SELECT
	MONTH(vc.fecha) AS "Mes", 
	r.nombre AS "Rubro",
	SUM(vd.cantidad) AS "Cantidad"
FROM
	vencab AS vc
	INNER JOIN vendet AS vd
	ON vc.factura = vd.factura AND vc.letra = vd.letra
	INNER JOIN articulos AS a
	ON vd.articulo = a.articulo
	INNER JOIN rubros AS r
	ON a.rubro = r.rubro
WHERE
	vc.anulada = 0
	AND YEAR(vc.fecha) = 2006
GROUP BY
	MONTH(vc.fecha),
	r.nombre
ORDER BY
	1, 3 DESC

/*
EJERCICIO 2

Calcular las comisiones que se deben pagar a los vendedores para el año 2007. Tener en cuenta:
- La comisión es del 3% sobre el total de las ventas
- Solamente se pagan comisiones si el vendedor superó los $ 100.000
- No incluir vendedores encargados (encargado = 'N')
- Solamente para vendedores activos (activo = 'S')
- Listar código, nombre, importe total ventas, comisión a pagar
- Ordenar por nombre de vendedor

TABLAS:
VENDEDORES (vendedor)
VENCAB (letra y factura)

*/

SELECT
	v.vendedor AS "Vendedor",
	v.nombre AS "Nombre",
	SUM(vc.total) AS "Total ventas 2007",
	SUM(vc.total * 0.03) AS "Comisión a pagar"
FROM
	vencab AS vc
	INNER JOIN vendedores AS v
	ON vc.vendedor = v.vendedor
WHERE
	v.activo = 'S'
	AND v.encargado = 'N'
	AND YEAR(vc.fecha) = 2007
GROUP BY
	v.vendedor,
	v.nombre
HAVING
	SUM(vc.total) > 100000
ORDER BY
	2