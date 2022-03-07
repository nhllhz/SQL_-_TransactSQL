USE Ventas2


---Consulta ganancias por sucursales
SELECT
	MONTH(vc.fecha) AS "MES",
	YEAR(vc.fecha) AS "AÑO",
	s.denominacion AS "SUCURSAL",
	SUM(vd.precio * vd.cantidad) AS "GANANCIAS"
FROM
	vencab AS vc INNER JOIN vendet AS vd ON (vc.letra = vd.letra AND vc.factura = vd.factura)
	INNER JOIN sucursales AS s ON vc.sucursal = s.sucursal
WHERE
	vc.anulada=0
GROUP BY
	MONTH(vc.fecha) ,
	YEAR(vc.fecha) ,
	s.denominacion
HAVING 
	SUM(vd.precio * vd.cantidad) > 1000
ORDER BY
	3, 2, 1



---Consulta productos vendidos por sucursal

SELECT
	MONTH(vc.fecha) AS "MES",
	YEAR(vc.fecha) AS "AÑO",
	s.denominacion AS "SUCURSAL",
	SUM(vd.cantidad) as "Cantidad"

FROM
	vencab AS vc 
	INNER JOIN vendet AS vd 
	ON (vc.letra = vd.letra AND vc.factura = vd.factura)
	INNER JOIN sucursales AS s 
	ON vc.sucursal = s.sucursal
	INNER JOIN articulos as a
	ON vd.articulo=a.articulo

WHERE
	vc.anulada=0

GROUP BY
	MONTH(vc.fecha) ,
	YEAR(vc.fecha) ,
	s.denominacion

ORDER BY
	3, 2, 1