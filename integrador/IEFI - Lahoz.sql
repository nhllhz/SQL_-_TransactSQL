USE Ventas2

/*
El artículo B107130014 es una Campera de Cuero clásica de alto valor, de la cual, cuando la empresa comenzó su actividad se distribuyeron 30 unidades en cada sucursal para su venta. 
Se precisa determinar el stock actual de ese artículo en cada sucursal, siempre y cuando sea mayor a cero. 
Listar el nombre de la sucursal, la cantidad vendida y la cantidad actual, ordenado por sucursal. (30 puntos)
*/

SELECT 

	s.denominacion as 'Sucursal',
	sum(vd.cantidad) as 'Cant vendida',
	(30 - sum(vd.cantidad)) as 'Disponibles'

FROM
	vendet as vd
	INNER JOIN 	articulos as a
	ON vd.articulo=a.articulo
	INNER JOIN vencab as vc
	ON vd.letra=vc.letra and vd.factura=vc.factura
	INNER JOIN sucursales as s
	ON s.sucursal= vc.sucursal
WHERE
	a.articulo= 'B107130014' 
	
GROUP BY 
	s.denominacion

HAVING
	(30 - sum(vd.cantidad)) > 0
ORDER BY 1


/*
Cree la vista v_comisiones_vendedores_2008, 
donde se calculen las comisiones que le corresponden a cada vendedor para cada mes del año 2008, 
de acuerdo con sus ventas, su antigüedad y su categoría (encargado o no encargado). (40 puntos) 

El criterio de cálculo de las comisiones es el siguiente: 
•	Si el vendedor es encargado, la comisión mensual es del 0.05, y se le pagan $500 adicionales por cada año de antigüedad.
•	Si el vendedor NO es encargado, la comisión mensual es de 0.03 y se le pagan $300 adicionales por cada año de antigüedad.
•	Solamente se deben pagar comisiones si el vendedor superó los $5000 en ventas por mes.

La vista debe mostrar el código del vendedor, 
el nombre, si es o no encargado, la antigüedad que tenía en el 2008, el mes, el importe total de ventas y la comisión a cobrar. 
Excluya ventas anuladas.

*/
CREATE OR ALTER VIEW v_comisiones_vendedores_2008 AS 
SELECT
	v.vendedor as 'Codigo Vendedor',
	v.nombre as 'Nombre',
	v.encargado as 'Encargado',
	(2008 - year(v.ingreso)) as 'Antiguedad',
	MONTH(vc.fecha) as 'Mes',
	SUM(vc.total) AS "Total ventas 2008",
	SUM((vc.total * 0.05)+(2008 - year(v.ingreso))*500) AS "Comisión a pagar"
FROM
	vencab as vc
	INNER JOIN vendedores as v
	ON v.vendedor = vc.vendedor
WHERE
	vc.anulada=0
	AND v.encargado = 'S'
	AND YEAR(vc.fecha) = 2008

GROUP BY
	v.vendedor,
	v.encargado,
	v.ingreso,
	MONTH(vc.fecha),
	v.nombre
HAVING
	SUM(vc.total) > 5000

UNION ALL

SELECT
	v.vendedor as 'Codigo Vendedor',
	v.nombre as 'Nombre',
	v.encargado as 'Encargado',
	(2008 - year(v.ingreso)) as 'Antiguedad',
	MONTH(vc.fecha) as 'Mes',
	SUM(vc.total) AS "Total ventas 2008",
	SUM((vc.total * 0.03)+(2008 - year(v.ingreso))*300) AS "Comisión a pagar"
FROM
	vencab as vc
	INNER JOIN vendedores as v
	ON v.vendedor = vc.vendedor
WHERE
	vc.anulada=0
	AND v.encargado = 'N'
	AND YEAR(vc.fecha) = 2008

GROUP BY
	v.vendedor,
	v.encargado,
	v.ingreso,
	MONTH(vc.fecha),
	v.nombre
HAVING
	SUM(vc.total) > 5000

select * from v_comisiones_vendedores_2008

/*
Cree el procedimiento almacenado sp_articulos_sin_ventas que, recibiendo como parámetro un año determinado, cree la tabla TmpArticulosSinVentas. 


Esta tabla deberá contener los artículos que no registraron ninguna venta en el año especificado. 

La estructura de la tabla debe ser: artículo (código), nombre, marca (nombre), rubro (nombre), preciomayor y preciomenor. 
El procedimiento deberá validar la existencia de la tabla y contar con manejo de errores y mensajes con el resumen de las filas insertadas. (30 puntos)
*/





CREATE OR ALTER PROCEDURE sp_articulos_sin_ventas
	@año int
AS
BEGIN
	DECLARE @f int
	IF OBJECT_ID('TmpArticulosSinVentas') is NULL
		
		SELECT
			a.articulo as 'Codigo articulo',
			a.nombre as 'Nombre articulo',
			a.marca as 'Marca',
			r.nombre as 'Nombre rubro',
			a.preciomenor as 'Precio menor',
			a.preciomayor as 'Precio mayor'

		INTO 
			TmpArticulosSinVentas
		FROM
			vendet as vd
			INNER JOIN 	articulos as a
			ON vd.articulo=a.articulo
			INNER JOIN vencab as vc
			ON vd.letra=vc.letra and vd.factura=vc.factura
			INNER JOIN rubros as r
			ON r.rubro=a.rubro
		WHERE
			vc.anulada=0 and
			year(vc.fecha)=@año 
		GROUP BY
			a.articulo,
			a.nombre,
			a.marca,
			r.nombre,
			a.preciomenor,
			a.preciomayor
		HAVING
			SUM(vd.cantidad) = 0

	ELSE
		BEGIN
			TRUNCATE TABLE 	TmpArticulosSinVentas
			--
			INSERT INTO TmpArticulosSinVentas
			SELECT
				a.articulo as 'Codigo articulo',
				a.nombre as 'Nombre articulo',
				a.marca as 'Marca',
				r.nombre as 'Nombre rubro',
				a.preciomenor as 'Precio menor',
				a.preciomayor as 'Precio mayor'

			FROM
				vendet as vd
				INNER JOIN 	articulos as a
				ON vd.articulo=a.articulo
				INNER JOIN vencab as vc
				ON vd.letra=vc.letra and vd.factura=vc.factura
				INNER JOIN rubros as r
				ON r.rubro=a.rubro
			WHERE
				vc.anulada=0 and
				year(vc.fecha)=@año 

			GROUP BY
				a.articulo,
				a.nombre,
				a.marca,
				r.nombre,
				a.preciomenor,
				a.preciomayor
			HAVING
				SUM(vd.cantidad) = 0
		END

		SET @f=@@ROWCOUNT

		IF @@ERROR <> 0
			PRINT 'Se produjo un error durante la inserción. Contacte con el administrador.'
		ELSE
			PRINT 'Se insertaron ' + TRIM(STR(@f)) + ' filas.'
END

EXEC sp_articulos_sin_ventas 20066

