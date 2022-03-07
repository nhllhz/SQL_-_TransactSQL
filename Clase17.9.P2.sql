USE Ventas2

-- CONSULTAS A VARIAS TABLAS

-- Extraer un listado de artículos de la marca AF (cualquier tipo).

SELECT -- Estos es subconsulta, preguntando por condiciones de columnas que estan en tablas diferentes. Se puede resolver de otra forma, mediante la recuperacion de datos de varias tablas
	articulo,
	nombre,
	marca
FROM
	articulos
WHERE
	marca IN (SELECT
				marca
			FROM
				marcas
			WHERE
				nombre LIKE '%AF%')
/*
Las consultass select y el lenguaje SQL estan basadas en teoria de conjuntos. 
Las op que se pueden hacer entre conjuntos se pueden hacer cpn conjuntos de datos
Trabajamos con tablas que son conjuntos de filas que tienen carac propias cada elemento, cada registro.

*/
-- CONDICIONES EQUIJUNTAS (forma antigua) 

SELECT
	a.articulo AS "Código",
	a.nombre AS "Nombre Artículo",
	m.nombre AS "Marca",
	r.nombre AS "Rubro"
FROM
	articulos AS a,
	marcas AS m,
	rubros AS r
WHERE
	a.marca = m.marca
	AND a.rubro = r.rubro
	AND a.nombre LIKE '%CAMPERA%'

-- CLAUSULA JOIN

SELECT
	a.articulo AS "Código",
	a.nombre AS "Nombre Artículo",
	m.nombre AS "Marca",
	r.nombre AS "Rubro"
FROM
	articulos AS a
	INNER JOIN marcas AS m 
	ON a.marca = m.marca
	INNER JOIN rubros AS r
	ON a.rubro = r.rubro
WHERE
	a.nombre LIKE '%CAMPERA%'

	
-- Listar los vendedores que realizaron ventas superiores a $100 en la primera quincena del mes de septiembre de 2006

SELECT
	s.denominacion,
	v.nombre,
	vc.fecha,
	vc.total
FROM
	vencab AS vc
	INNER JOIN vendedores AS v
	ON vc.vendedor = v.vendedor
	INNER JOIN sucursales AS s
	ON vc.sucursal = s.sucursal
WHERE
	vc.anulada = 0
	AND vc.fecha BETWEEN '2006-09-01' AND '2006-09-15'
	AND vc.total > 100
ORDER BY
	1, 2, 4 DESC

-- Listar las facturas en las que se vendieron REMERAS en el año 2007. Mostrar código, fecha, total de la factura,
-- y descripción del artículo.

SELECT DISTINCT  -- Filtro columnas
	vc.letra,
	vc.factura,
	vc.fecha,
	vc.total
	--,
	--a.articulo,
	--a.nombre,
	--r.nombre
FROM
	vencab AS vc
	INNER JOIN vendet AS vd
	ON vc.letra = vd.letra AND vc.factura = vd.factura
	INNER JOIN articulos AS a
	ON vd.articulo = a.articulo
	INNER JOIN rubros AS r
	ON a.rubro = r.rubro
WHERE -- Filtro filas
	vc.anulada = 0
	AND YEAR(vc.fecha) = 2007
	AND r.nombre LIKE '%REMERA%'


/*
EJERCICIO 1

Mostrar el nombre del vendedor y su fecha de ingreso, de todos los vendedores
que vendieron prendas de la marca 'B52' en el local de 'PATIO OLMOS' 
TABLAS: vencab, vendet, vendedores, articulos, marcas, sucursales
*/

SELECT
	DISTINCT
	v.nombre,
	v.ingreso
FROM
	vendedores v
	INNER JOIN vencab vc 
	ON vc.vendedor = v.vendedor
	INNER JOIN sucursales s 
	ON vc.sucursal = s.sucursal
	INNER JOIN vendet vd 
	ON (vc.letra= vd.letra AND vc.factura = vd.factura)
	INNER JOIN articulos a 
	ON vd.articulo = a.articulo
	INNER JOIN marcas m 
	ON a.marca = m.marca
WHERE
	m.nombre LIKE '%B52%'
	AND s.denominacion LIKE '%PATIO OLMOS%'
	AND vc.anulada = 0
ORDER BY
	v.nombre asc

/* 
EJERCICIO 2

La marca AF decidió enviar un obsequio a aquellos clientes que hicieron alguna compra mayorista de su artículos.
Identificar a esos clientes, su dirección (domicilio, localidad y cp). Excluya ventas anuladas y ordene por cliente.

TABLAS: mayorcab, mayordet, articulos, marcas, clientes

*/

SELECT DISTINCT
	--mc.cliente,
	c.nombre,
	c.domicilio,
	--c.localidad,
	c.cp,
	RTRIM(c.domicilio) + ' (' + RTRIM(c.cp) + ')' AS "Dirección" -- el signo + sirve para hacer una suma con datos numericos
	--si son del tipo sytring el + opera como concatenador
	--las columnas tipo char almacenan siempre su espacio completo, rellenan con espacio. VArchar si ocupa lo que usa realmente
	--RTRIM quita los espacios a la derecha 
FROM
	mayorcab AS mc
	INNER JOIN	mayordet AS md
	ON mc.letra = md.letra AND mc.factura = md.factura
	INNER JOIN articulos AS a
	ON md.articulo = a.articulo
	INNER JOIN marcas AS m
	ON a.marca = m.marca	
	INNER JOIN clientes AS c
	ON mc.cliente = c.cliente
WHERE
	mc.anulada = 0
	AND m.nombre LIKE '%AF%'
ORDER BY
	2


/*
EJERCICIO 3

Buscar para el mes de Setiembre de 2005, el nombre del vendedor, el nombre de la sucursal, 
la letra y número de factura, el código del articulo y su nombre, mostrando el precio
vendido y el precio de venta, para aquellos artículos que se vendieron a un valor inferior
del 10% menos del precio estipulado para la venta.

TABLAS: vencab, vendet, vendedores, articulos, sucursales
*/

SELECT
	v.nombre
	,s.denominacion
	,vd.letra
	,vd.factura
	,vd.articulo
	,a.nombre as NombArt
	,vd.precio as Vendido
	,vd.precioventa
FROM
	vendet AS vd
	INNER JOIN vencab AS vc on (vd.letra = vc.letra AND vd.factura = vc.factura)
	INNER JOIN sucursales AS s on vc.sucursal = s.sucursal
	INNER JOIN vendedores AS v ON vc.vendedor = v.vendedor
	INNER JOIN articulos AS a ON vd.articulo = a.articulo
WHERE
	vc.anulada = 0
	AND MONTH(vc.fecha) = 9
	AND YEAR(vc.fecha) = 2005
	AND vd.precio < vd.precioventa - (vd.precioventa * 10 / 100)

