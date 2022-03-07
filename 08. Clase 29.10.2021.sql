/*

VISTAS

- Es un objeto en la base de datos que se crea a partir de una instruccion select. 
- sirven para conservar consultas importantes
- Reducir la complejidad del modelo relacional
- CREATE, DROP, ALTER - instrucciones dml

Se comporta como si fuera una tabla, tiene columnas con el tipo de datos heredados de la tabla de origen de cada dato

*/

USE Ventas2


DROP VIEW v_resumen_ventas

/*Formar de borrar un objeto*/

CREATE OR ALTER VIEW v_resumen_ventas AS 

/*
cretae va seguido del tipo de objeto y despues del nombre del objeto.
Luego seguido de la instruccion as y luego todo el select.
Dentri del create view no va incluido el order by. Da error
*/



SELECT
	YEAR(vc.fecha) AS "Año",
	MONTH(vc.fecha) AS "Mes",
	'Ventas Minoristas' AS "TipoVenta",
	SUM(vc.total) "Total Vendido"
FROM
	vencab AS vc	
WHERE
	vc.anulada = 0
GROUP BY
	YEAR(vc.fecha),
	MONTH(vc.fecha)
--
UNION ALL
--
SELECT
	YEAR(mc.fecha) AS "Año",
	MONTH(mc.fecha) AS "Mes",
	'Ventas Mayoristas' AS "TipoVenta",
	SUM(mc.total) "Total Vendido"
FROM
	mayorcab AS mc	
WHERE
	mc.anulada = 0
GROUP BY
	YEAR(mc.fecha),
	MONTH(mc.fecha)


SELECT
	Año,
	SUM("Total Vendido")
FROM 
	v_resumen_ventas
GROUP BY
	Año
ORDER BY 
	1 DESC


EXEC sp_helptext v_resumen_ventas

EXEC sp_columns marcas

EXEC sp_columns [Astillero].[clientes]

EXEC sp_tables