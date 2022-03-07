use ventas2
/*

Listar la cantidad que se vendió de cada artículo (tanto mayorista como minorista) en el año 2007. Excluir ventas anuladas.

Presentar código de artículo, nombre y cantidad total vendida.

Ordenar por código de artículo.

sumar lo que vendi menos lo que me devolvieron y 
totalizar las cantidades vendidas de cada articulo minorista y las cant vendidas de cada articulo mayorista.
unirlos y que me devuelva uno solo 
*/ 

SELECT
	a.articulo,
	a.nombre,
	SUM(md.cantidad+vd.cantidad)  as "Articulos"

FROM
	vendet as vd
	INNER JOIN articulos as a
	ON a.articulo= vd.articulo
	INNER JOIN vencab as vc
	ON vd.factura = vc.factura 
	INNER JOIN mayordet as md
	ON md.articulo=a.articulo
WHERE
	vc.anulada=0
	and YEAR (vc.fecha) = 2007
group by
		a.articulo, 
		a.nombre
