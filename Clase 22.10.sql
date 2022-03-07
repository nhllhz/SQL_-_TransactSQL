USE Ventas2

/*

CLASE 22/10

Modificación de datos

*/

--
-- INSERT -----
/*
Permite insertar filas nuevas en las tablas.
Tiene 3 posibles formas de ser implementado.

Simple: Insertar una fila en una tabla. Puede ir dentro de un bucle

INSERT INTO : INICIO DE LA INSTRUCCION
seguido de el nombre de LA TABLA
Luego entre () le pasas el nombre de las col a las cual les pasas valor
Luego los valores, en el mismo orden de las columnas. Con el tipo de dato correspondiente

¿Siempre que se realiza un insert into en una tabla deben asignare valores para todas las columnas? Lo indica en el tipo de dato. Ahi dice si puede ser o no nula.
Tengo la obligacion de poner las columnas que son notnull. Tener en cuenta tipo de dato y longittud igual

*/
--

SELECT * FROM MARCAS

INSERT INTO marcas 
	(marca, nombre, activo) 
VALUES 
	('V','NUEVA MARCA','N')

/*
En un momento se pone a hablar de vistas que permitan recibir transacciones (No se que es lo de vistas)


-- Fuinciona igual sin INTO, PERO NO CONVIENE NO PONERLO.

La complejidad esta dada por la tabla y la cantidad de columnas sde la misma

Si voy a la tabla y le hago click derecho. Voy a script table as. INSERT. y reemplazo.


*/

INSERT marcas
	(marca, nombre)
VALUES
	('W','WRANGLER')



TRUNCATE TABLE encargados  --- Borrar todas las filas. Mas simple que el delete(objetivo borrar filas). Este vacia una tabla, manteniendo la esttructura.
-- en el delete se puede rollbackear (si te arrepentiste y eliminaste, lo volves), en este no. 




-- INSERT SELECT (Inserta en una tabla existente a partir de un select)
/*

-- Existe la posibilidad de hacer inserciones de forma masivas en las tablas. A traves de una sola instruccion insert insertar muchas filas
Hay dos variantes. INSERT SELECT Y SELECT INTO

Se diferencia del otro

Sintaxis diferente. Insert into primero pero luego sigue una instruccion select

Hace casi lo mismo que el otro. Nada mas que la tabla tiene que existir (clave).     
Hay que tener en cuenta el que el resultado del select tenga la misma cantidad de columnas que yo tengo en la tabla.
 

*/



INSERT INTO encargados
SELECT 
	dni,
	nombre,
	ingreso,
	activo 
FROM 
	vendedores 
WHERE
	encargado = 'S'





-- SELECT INTO (Inserta y crea una tabla nueva a partir de un select)
/*
eS UNA CONSULTA SELECT q lo q hace es generar adtos de origen para crear una nueva tabla con esas filas.
El resultado del SELECT lo inserte en una tabla nueva que crea. En el caso de abajo "encargados". 
Si la tabla existe, da error. Sino la crea
Despues de las columnas del select y antes del from.
Las columnas de las tabla nueva son aquellas que pido en el select. Si le pongo 'AS' las guarda con ese nombre.
el tipo de dato, la dimension y si es null o not null es heredado de la tabla de origen.
Crea la tabla e inserta el resultado del select.

¿Cuando se hace la creacion de esta nueva tabla como podemos o se puede hacer para determianr una columna como clave primaria?
*/

SELECT
	dni,
	nombre,
	ingreso,
	activo
INTO 
	encargados
FROM
	vendedores 
WHERE 
	encargado = 'S'



SELECT * FROM ENCARGADOS




INSERT INTO encargados
	(dni,nombre,ingreso,activo)
VALUES
	(99999999,'ENCARGADO NUEVO',GETDATE(),'S')


SELECT 
	articulo,
	nombre
INTO
	temp_articulos
FROM 
	articulos
WHERE
	rubro = 78



INSERT 
	temp_articulos 
SELECT
	articulo,
	nombre
FROM 
	articulos
WHERE
	rubro = 25



select * from temp_articulos


drop table temp_articulos
--DROP: borrar tablas. Misma naturaleza que el create view
drop table encargados







--
-- UPDATE  ---
--
/*
Me permite modificar los valores de una columna o conjunto de ellas. O de una fila o conjunto de ellas. Dependera de como plantee la instruccion
Sintaxis: UPDATE -nombre de la tabla- SET -conjunto de valores que le asigno a cada columna, separados por coma. Luego la condicion que tienen que cumplir para ser actualizados.
Si omito el where se lo pone a todo.

*/

SELECT * FROM TEMP_MARCAS

drop table TEMP_MARCAS

SELECT * INTO temp_marcas FROM marcas


UPDATE temp_marcas
SET nombre = 'VANS', activo = 'S' 
WHERE
marca = 'V'



UPDATE temp_marcas
SET activo = 'S' 
WHERE
marca = 'W'



-- ROLLBACK / COMMIT
/*
Nos permiten confirmar o volver atras los cambios que hicimos a traves de instrucciones (update, delete, insert) de acuerdo a una cierta condicion que evaluo
Si todo salio bien, le mando commit. Si algo salio mal le hago un rollback y me vuelve patras. 
Hay que entender el bloque de transacciones.
Transac SQL

*/



SELECT * FROM TEMP_SUCURSALES

SELECT * FROM SUCURSALES

DROP TABLE temp_sucursales



select *
into temp_sucursales 
from sucursales



UPDATE temp_sucursales
SET direccion = UPPER(direccion) -- Esta funcion me pasa una cadena a MAYUS



UPDATE temp_sucursales
SET direccion = LOWER(direccion) -- Esta las pasa a minuscula
WHERE sucursal = 8



UPDATE temp_sucursales
SET direccion = 'LOS ROBLES 228 - SAN LUIS'
WHERE sucursal = 7

-- Se puede conectarf con un inner join para poder hacer actualizacion con condiciones de multiples tablas.





--
-- DELETE / TRUNCATE ---- 
--
/*

*/




DELETE FROM marcas
WHERE marca IN('W','V')

SELECT * FROM MARCAS

TRUNCATE TABLE temp_sucursales


-- Ejemplo de borrado con INNER JOIN

-- Necesito evaluar condiciones de otras tablas para poder tomar una accion 

DELETE vendet
--
FROM vendet as vd
INNER JOIN vencab as vc
ON vd.letra = vc.letra and vd.factura = vc.factura
WHERE
vc.fecha between ... and ...


/*

EJERCICIO 1: INSERTAR FILAS

a) Cree la tabla ACCESORIOS (rubros 76, 85, 77, 97, 70, 72, 87, 88) que tenga las columnas ARTICULO, NOMBRE,
PRECIOMAYOR y PRECIOMENOR tomando los datos de la tabla artículos. Utilice SELECT INTO.
b) Agregue a la tabla ACCESORIOS los artículos del rubro 89. Utilice INSERT SELECT.
c) Inserte un nuevo artículo con el código 'E000000001', denominado 'ELEMENTO ACCESORIO' con los precios 15 y 23.50
para ventas mayoristas y minoristas respectivamente.

En todos los casos verifique la correcta inserción de las filas mediante instrucciones SELECT de comprobación.

*/


SELECT
	ARTICULO, 
	NOMBRE,
	PRECIOMAYOR,
	PRECIOMENOR
INTO 
	accesorios
FROM
	articulos as a
WHERE 
	a.rubro in (76, 85, 77, 97, 70, 72, 87, 88)





INSERT INTO accesorios
SELECT 
	ARTICULO, 
	NOMBRE,
	PRECIOMAYOR,
	PRECIOMENOR 
FROM
	articulos as a
WHERE 
	a.rubro = 89




INSERT INTO accesorios
           (ARTICULO,
		   NOMBRE,
		   PRECIOMAYOR,
		   PRECIOMENOR)
VALUES
           ('E000000001',
           'ELEMENTO ACCESORIO',
           '15',
           '23.50')

select * from accesorios where articulo='E000000001'

/*

EJERCICIO 2: MODIFICACIÓN DE DATOS

a) Usando la tabla ACCESORIOS creada anteriormente, modifique los artículos que tengan PRECIOMAYOR negativo
(menor a cero), reemplazando el valor negativo por cero (0)
b) Usando la tabla ACCESORIOS, reemplace el valor del PRECIOMENOR por PRECIOMAYOR * 1.10 (10% más) para
aquellos artículos en los que el PRECIOMENOR sea menor o igual al PRECIOMAYOR.

*/

----
SELECT
 
	NOMBRE,
	PRECIOMAYOR,
	PRECIOMENOR
INTO 
	temp_accesorios
FROM
	accesorios




select * from temp_accesorios where preciomayor < 0

UPDATE temp_accesorios
SET preciomayor = 0 
WHERE
preciomayor < 0




select * from temp_accesorios where preciomenor <= preciomayor


UPDATE temp_accesorios
SET preciomenor =( preciomayor * 1.10 )
WHERE
preciomenor <= preciomayor



DROP TABLE temp_accesorios


----


select * from accesorios where preciomayor < 0

UPDATE accesorios
SET preciomayor = 0 
WHERE
preciomayor < 0



select * from accesorios where preciomenor <= preciomayor


UPDATE accesorios
SET preciomenor =( preciomayor * 1.10 )
WHERE
preciomenor <= preciomayor





/*

EJERCICIO 3: ELIMINACION DE FILAS

a) Usando la tabla ACCESORIOS, borre las filas que correspondan a artículos que contengan la palabra OUTLET en su nombre
o que tengan valor cero en ambos precios (preciomayor y preciomenor)
b) Elimine la tabla ACCESORIOS.

*/
---
select * from temp_accesorios WHERE NOMBRE LIKE '%OUTLET%'

select * from temp_accesorios WHERE (PRECIOMAYOR=0 AND PRECIOMENOR = 0)

DELETE FROM temp_accesorios
WHERE NOMBRE LIKE '%OUTLET%'OR (PRECIOMAYOR=0 AND PRECIOMENOR = 0)



DROP TABLE temp_accesorios
----




select * from accesorios WHERE NOMBRE LIKE '%OUTLET%'

select * from accesorios WHERE (PRECIOMAYOR=0 AND PRECIOMENOR = 0)

DELETE FROM accesorios
WHERE NOMBRE LIKE '%OUTLET%'OR (PRECIOMAYOR=0 AND PRECIOMENOR = 0)

DROP TABLE accesorios