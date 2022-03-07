
-- OPERADOR LOGICO

SELECT 
	articulo,
	nombre,
	preciomenor,
	preciomayor
FROM
	articulos

WHERE
	(preciomenor >= 100	AND preciomenor <= 200) 
	OR (preciomayor >= 50	AND preciomayor<= 90)--se pueden usar operadores logicos como and y or

/*operador de cadena 
like y not like 
comparamos el contenido de una cadena con un valor de una columna que quisieramos recuperar. 
se usan principalmente en el bloque where
*/
SELECT * FROM sucursales

-- para filtrar sucursales segun nombre

SELECT 
	sucursal,
	denominacion, 
	direccion
FROM
	sucursales
WHERE
	direccion LIKE '%Loc%' -- el porcentaje es un simbolo comodin que sirve para que no importe lo que haya a la izq o derecha de loc sino que contenga loc en cualquier posicion de la cadena. Si lo pongo a la derecha digo las direcciones que empiezan con loc

/*
Vamos a buscar a todos los vendedores que se llamen ponele juan
*/

SELECT 
	vendedor,
	nombre
FROM 
	vendedores
WHERE
	nombre LIKE '%Maria%'
/*
Vamos a buscar a todos los vendedores que no se llamen ponele juan
*/

SELECT 
	vendedor,
	nombre
FROM 
	vendedores
WHERE
	nombre NOT LIKE '%Maria%' --conjunto complementario, niega el like. Todos los que no se llamen maria



/*
OPERADORES DE INTERVALO
*/

--LISTAR QUE FACTURAS SE HCIERON 'X' DIA

SELECT
	letra,
	factura,
	fecha,
	vendedor,
	total
FROM
	vencab
WHERE
	fecha >='2007-10-01' -- conviene usar modelo año mes dia, para que no salten errores
	AND fecha <= '2007-10-31' 

--- hay un operador que me sirve para comparar periodos entre limite inferior y superior. 
-- Se llama BETWEEN	

SELECT
	letra,
	factura,
	fecha,
	vendedor,
	total
FROM
	vencab
WHERE
	fecha BETWEEN '2007-10-01' AND '2007-10-31' --primero inferior luego superior
	AND total BETWEEN 100 AND 150  -- los limites deben ser del mismo tipo de datos y de la columna que estoy comparando

/*
OPERADORES DE LISTA "IN"
*/

SELECT * FROM marcas WHERE nombre LIKE '%2da%'  -- listar todos los articulos que pertenecen a marcas de 2° o 3°

--- que articulos son marcas de 2°

SELECT 
	articulo,
	nombre,
	preciomenor,
	preciomayor,
	marca
FROM
	articulos
/*
WHERE
	MARCA = 'c' OR 'F' --- con or seria tedioso ir poniendo cada uno
*/

WHERE 
	marca IN ('C','D','E','F','L','M','N','P','Z')--array de valores para comparar con la columna marca- TAMBIEN SE PUEDE USAR EL NOT, PARA BUSCAR COSAS qUE NO SEAN DE ESTE MARCA POR EJEMPLO

---pseudocolumnas --no modifican la base de datos




SELECT
	'holi' as "psudo1",
	'chau' as "pseudo2",
	(154+7)*98 as "cuentita",
	GETDATE() as "la fecha",
	DAY(GETDATE()) as "numero de dia",
	MONTH(GETDATE()) as "numero de mes",
	YEAR(GETDATE()) as "numero de año"

-- vemos esto xq las funciones son utilies para cualuierr parte del select

SELECT
	letra,
	factura,
	fecha,
	vendedor,
	total
FROM
	vencab
WHERE
	--fecha BETWEEN '2007-01-01' AND '2007-03-31' -- primer trimestre 2007
	year(fecha)=2007 AND MONTH(fecha) in (1,2,3)--otra forma de resolver sin el between
	

--articulos con dif ilogica en los precios. Mayorista precio mayor al minorsta

SELECT 
	articulo,
	nombre,
	preciomenor,
	preciomayor,
	preciomayor - preciomenor as "diferencia"  -- creacion de psuedocolumna para que se calcule y anote la diferencia entre el calculo de las dos columnas
FROM
	articulos

WHERE
	preciomayor > preciomenor
	AND (preciomayor - preciomenor)>10


/* 
alias es el as
*/

---Para ordenar un cponjunto de valores devuelto. Si no le digo me lo muestra como le pinta, en la forma mas rapida que lp recucpera. Si por ejemplo quiero que sea por el nombre
--- se hace a traves de un 4 bloque llamado

/*
ORDER BY

Clausula que va SIEMPRE al ultimo, es el 4 bloque.
Primero recupera todas las filas; una vez que las tiene, las ordena
Puedo especificar un numero que 
*/

ORDER BY -- puede llamar a la columna por nombre o posicion
	--nombre --ordena ascedente

	nombre DESC -- ordenados decreciente

---OTRO
 SELECT * FROM vencab WHERE anulada=1 ORDER BY	3, total DESC  -- asi o esctructurado lo lee bien



 ---    DISTINCT ----
/*

Toma los resultados y me elimina todos los duplicados de ese conjunto de resultados
Siempre se pone el select
*/



 ---    SUBCONSULTA ----
/*

Listar los articulos de la marca AF
TUVE QUE RECURRIR A DOS CONSULTAS, UNA PÁRA SACAR LOS CODIGOS Y OTRAS PARA SACAR LOS ARTICULOS CORRESPONDIENTES. Fueron dos pasos


Es una consulta anidada en otra. El resultado de una copnsulta lo utilio como argumento para pasarle a otra consulta
*/
select * FROM marcas WHERE nombre LIKE '%AF%' -- Lista todas los nombres que contengan en su cadena un AF 

SELECT 
	articulo,
	nombre,
	preciomenor,
	preciomayor,
	marca
FROM
	articulos

	---para filtrar los articulos de la marca af incluimos en la clausula where 
WHERE 
	marca IN ('A','F','J','N','T')


--- Usando subconsulta se puede resolver en un solo paso

--- El IN es un operador que recibe datos del mismo tipo, coherentes y consistentes.


SELECT 
	articulo,
	nombre,
	preciomenor,
	preciomayor,
	marca
FROM
	articulos

	
WHERE 
	marca IN (select marca FROM marcas WHERE nombre LIKE '%AF%') --- El resultaado pasa al in como lista de valores 

---ESO ES UNA SUBCONSULTA --- OTRO EJEMPLO



/*

saber cual fue la venta de mayor importe sin importar el vendedor que la hizo
Listar los vendedores qie em el año 2008 superaron la mejor venta del 2007
*/

SELECT
	total

FROM
	vencab
WHERE
	YEAR(fecha)=2007
	and anulada=0  ---- Todas las ventas del 2007

ORDER BY 
	1 DESC --- Factura de mayor importe. Oredenado en descendente. Se puede hacer sin el order by

/*
Aplicar funcion max. Obtiene el valor mayor
*/

SELECT
	MAX(total)

FROM
	vencab
WHERE
	YEAR(fecha)=2007
	and anulada=0

	--- Año 2008
select distinct
	vendedor,
	---total
FROM
	vencab
WHERE

	YEAR(fecha)=2008
	and anulada=0
	AND total > 2625


---- Lsitar en una sola

select distinct
	vendedor
	---total
FROM
	vencab
WHERE

	YEAR(fecha)=2008
	and anulada=0
	AND total > (SELECT
					MAX(total)

				FROM
					vencab
				WHERE
					YEAR(fecha)=2007
					and anulada=0)