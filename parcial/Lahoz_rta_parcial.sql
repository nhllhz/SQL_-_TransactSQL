USE Ventas2
    
/*	
Desarrolle una consulta que presente Art�culo, Nombre, Total y TipoVenta (Mayor o Menor), 

y que muestre aquellos art�culos pertenecientes a marcas activas (ACTIVO = 'S') 

que vendieron como m�nimo $5000 en cualquiera de los tipos de venta en el a�o 2006. 

Excluya siempre las ventas anuladas, y tome para el c�lculo de los totales CANTIDAD * PRECIO para ventas minoristas, 

y CANTIDAD * PRECIO REAL para ventas mayoristas. 
Ordene por c�digo de art�culo y tipo de venta. (30 puntos) 
*/

SELECT
	'Min' as "tipo venta",
	a.articulo,
	a.nombre,
	SUM(vd.cantidad*vd.precio) as 'Total'	

FROM
	vendet as vd
	INNER JOIN articulos as a
	ON vd.articulo = a.articulo
	INNER JOIN vencab as vc
	ON vd.letra = vd.letra and vc.factura = vd.factura
	INNER JOIN marcas as m
	ON m.marca= a.marca

WHERE
	vc.anulada=0 and
	YEAR(vc.fecha) = 2006 and
	m.ACTIVO = 'S'

GROUP BY
	a.articulo,
	a.nombre

HAVING

	SUM(vd.cantidad*vd.precio) > 5000
	
UNION

SELECT
	'May' as "tipo venta",
	a.articulo,
	a.nombre,
	SUM(md.cantidad*md.precioreal) as 'Total'	

FROM
	mayordet as md
	INNER JOIN articulos as a
	ON md.articulo = a.articulo
	INNER JOIN mayorcab as mc
	ON md.letra = md.letra and mc.factura = md.factura
	INNER JOIN marcas as m
	ON m.marca= a.marca

WHERE
	mc.anulada=0 and
	YEAR(mc.fecha) = 2006 and
	m.ACTIVO = 'S'

GROUP BY
	a.articulo,
	a.nombre

HAVING

	SUM(md.cantidad*md.precioreal) > 5000

ORDER BY
	2,1




/*

Determine en una sola consulta los art�culos (c�digo, nombre e importe) 

que generaron m�s ventas mayoristas (en importe) en el a�o 2006 que el art�culo A205221022 en el 2005. 

Excluya siempre las ventas anuladas. 

Utilice para el c�lculo de los totales CANTIDAD * PRECIOREAL.

deteminar las vrntas de ese articulo en 2005 y despues ver en 2006 cuales superaron
subconsulta

cantidad x precio real y totalizar x articulo y x a�o en una caso
*/
SELECT 
	a.articulo,
	a.nombre,
	SUM(md.cantidad*md.precioreal) as 'Importe'

FROM 
	
	mayordet as md
	INNER JOIN articulos as a
	ON md.articulo = a.articulo
	INNER JOIN mayorcab as mc
	ON md.letra = md.letra and mc.factura = md.factura

	
WHERE 
	mc.anulada=0 and
	YEAR(mc.fecha) = 2006

GROUP BY
	a.articulo,
	a.nombre

HAVING
	SUM(md.cantidad*md.precioreal) > (
	
	SELECT 
	SUM(md.cantidad*md.precioreal) 
	
	FROM 
	
		mayordet as md
		INNER JOIN articulos as a
		ON md.articulo = a.articulo
		INNER JOIN mayorcab as mc
		ON md.letra = md.letra and mc.factura = md.factura

	
	WHERE 
		mc.anulada=0 and
		a.articulo = 'A205221022' and 
		YEAR(mc.fecha) = 2005 )





/*
La empresa decidi� pagar un premio equivalente al 3% de las ventas generadas en el a�o 2008 
por los vendedores que no son encargados (ENCARGADO = 'N'), est�n activos (ACTIVO = 'S'), 
y superaron los $100.000 en ventas en el a�o. 

Adem�s, debe cumplir la condici�n de haber tenido una antig�edad en el a�o 2008 de al menos 3 a�os para recibir el premio.
Para calcular la antig�edad deber� tomar el a�o de la fecha de ingreso. 
Liste el nombre del vendedor, su antig�edad, el total vendido en el 2008, y el valor del premio a pagar. 
Ordene por vendedor y excluya ventas anuladas. 
*/


SELECT
	v.vendedor AS "Vendedor",
	v.nombre AS "Nombre",
	(2008 - year(v.ingreso)) as 'Antiguedad',
	SUM(vc.total) AS "Total ventas 2008",
	SUM(vc.total * 0.03) AS "Comisi�n a pagar"
FROM
	vencab AS vc
	INNER JOIN vendedores AS v
	ON vc.vendedor = v.vendedor
WHERE
	v.activo = 'S'
	AND vc.anulada=0
	AND v.encargado = 'N'
	AND YEAR(vc.fecha) = 2008
GROUP BY
	v.vendedor,
	v.nombre,
	v.ingreso

	
HAVING
	SUM(vc.total) > 100000 and 
	(2008 - year(v.ingreso))  >= 3 

ORDER BY
	1