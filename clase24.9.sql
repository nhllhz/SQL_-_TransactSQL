/*
AGRUPAMIENTO DE DATOS
TOP: limita la cantidad de filas del resultados, devuelve n filas
Hacer resumen de datos de acuerdo a cietos criterios.
Se agrupan columnas y se dividen en dos grupos ppales:
Los criterios de agrupamiento: aquellas columnas o combinacion de ellas donde cualquier cambio que se haga hay que hacer un corte de control y totalizar el dato
Las funciones de agrupamiento: op matematica que queremos hacer una vez que se cumpla la condicion de los criterios de agrup.
*/

USE Ventas2
/*
Primero rescato los datos en brutos, despues los filtro y agrupo

en la clausula GROUP BY se establecen los criterios de agrupamiento
*/


-- DETERMINAR PARA CADA AÑO EL MAYOR IMPORTE DE UNA FACTURA

SELECT
	YEAR(fecha) AS "Año", -- Criterio de agrupamiento
	MAX(total) AS "Importe" -- Función de agrupamiento
FROM
	vencab
WHERE
	anulada = 0
GROUP BY -- Cyuales son las columnas por las cuales quiero hacer los cortes de control

-- No se se pueden usar alias en el GROUP BY

	--Definimos la columna por la que queremos hacer el agrupamiento
	YEAR (fecha)
ORDER BY
	1


/*Existen diversas funciones de agrupamiento. En el TID esta especificadas*/

-- DETERMINAR EL IMPORTE COMPRADO POR CADA CLIENTE EN CADA AÑO DE FORMA MAYORISTA

SELECT
	c.nombre, 
	YEAR(mc.fecha) as "AÑO",
	SUM(mc.total) as "TOTAL COMPRA"

FROM

	mayorcab as mc
	INNER JOIN clientes as c
	ON mc.cliente= c.cliente

WHERE

	mc.anulada=0

group by

	c.nombre, 
	YEAR(mc.fecha) 

ORDER BY

	1,2

-- DETERMINAR EL TOTAL VENDIDO (MINORISTA) POR AÑO Y POR MES (EXCLUIR VENTAS ANULADAS)

SELECT
	year(fecha) as "Año",
	MONTH(fecha) as "Mes",
	SUM(total) as "Total vendido"

FROM

	vencab

WHERE
	anulada=0
GROUP BY
	year(fecha),
	MONTH(fecha)

HAVING 
 	SUM(total) < 500000
ORDER BY
	1,2


---Si quisiera listar aquellas ventas que superaron los $500.000. Filtrarlas
-- No se puede usar el where, ya que es el que me filtra los datos antes de dvolvermelos en bruto y que luego seran agrupados

/*CLAUSULA HAVING
Es como un where aplicado a los datos ya agrupados.
Condiciones que deben cumpliri los datos ya agrupados.
bloque permite establecer filtros sobre datos agrupados

*/





-- DETERMINAR EL TOTAL VENDIDO (MAYORISTA) POR AÑO Y POR MES (EXCLUIR VENTAS ANULADAS)

SELECT
	year(fecha) as "Año",
	MONTH(fecha) as "Mes",
	SUM(total) as "Total vendido"

FROM

	mayorcab

WHERE
	anulada=0
GROUP BY
	year(fecha),
	MONTH(fecha)
HAVING 
 	SUM(total) < 500000
ORDER BY
	1,2

 ----- UNION / UNION ALL ---------
 /*
 
 El algebra de conjuntos nos permite hacer operaciones entre grupos de elementos.
 Uno es la union o union completa


 union all -- trae en el conjunto resultante todas las apariciones

 Cuando hago la union entre dos conjuntos, los elementos deben ser del mismo tipo.
 Nuestros conjuntos son las tablas o los resultados de los Selects
 Se concatenan las diversas instrucciones select con la clausula UNION
 Sirve para sumar dos conjuntos de filas, que deben tener la misma cant de columnas y del mismo tipo
 El resultante es un unico conjunto de datos

 */

 SELECT
	'Min' as "tipo venta", -- pseudocolumna
	year(fecha) as "Año",
	MONTH(fecha) as "Mes",
	SUM(total) as "Total vendido"

FROM

	vencab

WHERE
	anulada=0
GROUP BY
	year(fecha),
	MONTH(fecha)

HAVING 
 	SUM(total) < 1000000

---

	UNION

---El union all trae los duplicados y el union solo no los trae
--- Me permite establecer la union de los elementos de varios conjuntos (instr. select que devuelven conjuntos de filas)

----
SELECT
	'May' as "tipo venta", -- pseudocolumna
	year(fecha) as "Año",
	MONTH(fecha) as "Mes",
	SUM(total) as "Total vendido"

FROM

	mayorcab

WHERE
	anulada=0
GROUP BY
	year(fecha),
	MONTH(fecha)
HAVING 
 	SUM(total) < 1000000
ORDER BY
	2,3,1


/*
	DETERMINAR LAS SUCURSALES QUE EN EL AÑO 2006 SUPERARON LAS 500 VENTAS MENSUALES. DETALLAR EL MES
Y LA CANTIDAD DE VENTAS (COUNT)

*/

SELECT
	s.denominacion,
	MONTH(vc.fecha) as "Mes",
	COUNT(vc.factura) as "Facturas"


FROM
	vencab as vc
	INNER JOIN sucursales as s
	ON vc.sucursal = s.sucursal
WHERE
	vc.anulada = 0
	AND YEAR(vc.fecha) = 2006

GROUP BY
	s.denominacion,
	MONTH(vc.fecha)
HAVING
	COUNT(vc.factura) > 1000
ORDER BY
	1,2

---el del profe

SELECT
	s.denominacion,
	MONTH(vc.fecha),
	--vc.letra,
	COUNT(vc.factura)
FROM
	vencab AS vc
	INNER JOIN sucursales AS s
	ON vc.sucursal = s.sucursal
WHERE
	vc.anulada = 0
	AND YEAR(vc.fecha) = 2006
GROUP BY
	s.denominacion,
	MONTH(vc.fecha)
HAVING
	COUNT(vc.factura) > 1000
ORDER BY
	1,2


---------------------ejercicios---------------
/*

Determinar la comision por ventas para cada local, mostrando nombre de local, mes, importe total de ventas, comision.
Calcular para el año 2006. Para aplicar al comision se utilizará un porcentaje de 1.7 % sobre el total de la venta.

TABLAS: SUCURSALES (sucursal) VENCAB (sucursal)

*/

SELECT
	s.denominacion,
	MONTH(vc.fecha) as "mes",
	SUM(vc.total) as "total ventas",
	SUM((1.7*vc.total)/100) as "comision"
FROM
	vencab as vc
	INNER JOIN sucursales as s
	ON vc.sucursal=s.sucursal
WHERE

	YEAR(vc.fecha)=2006 and
	vc.anulada=0

GROUP BY

	MONTH(vc.fecha),
	s.denominacion	

ORDER BY

	1,2,3

/*

EJERCICIO 2

Determinar los 50 mejores clientes mayoristas. Hacer el ranking de compra mostrando aquellos que compraron mas 
de 1000 prendas y gastaron mas de 50000 pesos en el primer semestre de 2006. Excluir ventas anuladas.

TABLAS: CLIENTES (cliente), MAYORCAB (cliente) (letra y factura), MAYORDET (letra y factura)

*/


---top
SELECT TOP 50
	c.nombre,
	MONTH(mc.fecha) as "Mes",
	sum(mc.total) as "Gastado",
	count(md.cantidad) as "Articulos"
	

FROM 
	mayorcab as mc
	INNER JOIN clientes as c
	ON mc.cliente= c.cliente
	INNER JOIN mayordet as md
	ON  mc.factura =  md.factura and mc.letra = md.letra
WHERE
	anulada=0 and
	month(fecha) BETWEEN '1' AND '6' 
	and YEAR (fecha) = 2006

GROUP BY
	c.cliente,
	fecha


HAVING

	sum(mc.total) > 50000 and
	count(md.cantidad) > 100

ORDER BY

	4,1,3,2 desc
	


SELECT TOP 50
	c.nombre,
	MONTH(mc.fecha) as "Mes",
	SUM(md.cantidad * md.precioreal) as "Gastado",
	SUM(md.cantidad) as "Articulos"
FROM 
	mayorcab as mc
	INNER JOIN clientes as c
	ON mc.cliente= c.cliente
	INNER JOIN mayordet as md
	ON  mc.factura =  md.factura and mc.letra = md.letra
WHERE
	mc.anulada=0 and
	month(mc.fecha) BETWEEN 1 AND 6 
	and YEAR (mc.fecha) = 2006
GROUP BY
	c.nombre,
	MONTH(mc.fecha)
HAVING
	SUM(md.cantidad * md.precioreal) > 5000 and
	SUM(md.cantidad) > 100
ORDER BY
	3 desc