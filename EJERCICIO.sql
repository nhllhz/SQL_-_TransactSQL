/*
LISTAR CODIGOS DE SUCURSSALES EN LAS QUE SE HICIERON VENTAS MAYORES A 1000 EN MAYO 2007
NO VENTAS ANULADAS
USAR SOLO VENCAB
*/

SELECT DISTINCT -- ELIMINA REPETICIONES
	sucursal
	
fROM
	vencab
WHERE

	total > 1000 
	AND fecha BETWEEN '2007-05-01' AND '2007-05-31' 
	AND anulada = 0

	---     17/9/2021 -----
/*

EJERCICIO 2: LISTE LOS ARTICULOS DE TIPO "CINTO" DADOS DE ALTA EN EL AÑO 2006, CUYO PRECIO MAYORISTA SEA MENOR A SU PRECIO 
MINORISTA. ADEMÁS TENER EN CUENTA QUE LA MARCA SEA 'A','F' o 'Q', Y QUE AMBOS PRECIOS SEAN MAYORES A CERO. PRESENTE: CÓDIGO,
NOMBRE, MARCA, PRECIO X MAYOR, PRECIO X MENOR, Y DIFERENCIA ENTRE AMBOS. ORDENE EN FORMA DECRECIENTE POR LA DIFERENCIA 
DE PRECIOS.

*/

SELECT  
	articulo,
	nombre,
	marca, 
	preciomayor,
	preciomenor,
	preciomayor-preciomenor as 'Diferencia'
	

FROM
	articulos

WHERE
	nombre LIKE '%CINTO%'
	---AND creado BETWEEN '2006-01-01' AND '2006-12-31'
	AND year(creado)=2006
	AND marca IN ('A','F' , 'Q')
	AND preciomayor < preciomenor
	AND (preciomayor<>0 AND preciomenor<>0) --- Use "DISTINTO DE" capaz esta mal porque puede dar valores negativos tambien, aunque no es el caso

ORDER BY 
	Diferencia DESC
	





/*

EJERCICIO 3: PRESENTE EL CÓDIGO, EL NOMBRE Y LA SUCURSAL DE LOS VENDEDORES QUE SEAN ENCARGADOS, QUE ESTÉN ACTIVOS
Y QUE ALGUNA VEZ RECIBIERON UNIFORME (tabla uniformes). UTILICE SUBCONSULTA.

*/

SELECT   ---- el codigo es la columna vendedor?
	vendedor, 
	nombre, 
	sucursal 

	
FROM
	vendedores


WHERE

	(encargado = 'S' ) AND (activo = 'S' )
	AND vendedor IN (SELECT vendedor FROM	uniformes)



							/*INNER JOIN*/

SELECT   
	v.vendedor, 
	v.nombre, 
	v.sucursal 

	
FROM
	vendedores AS v
	INNER JOIN uniformes as u 
	ON v.vendedor= u.vendedor


WHERE

	(v.encargado = 'S' ) AND (v.activo = 'S' )





USE Ventas2

/*

Construir el SP que permita insertar una nueva marca, solicitando como parámetros los tres valores, y que devuelva el mensaje
'La marca [nombre] se insertó correctamente', pero si no presentar el mensaje 'Hubo un problema! No se pudo insertar la marca.'

*/

CREATE or ALTER PROCEDURE sp_nuevamarca
	@marca char(1),
	@nombre char(30),
	@activo char(1)
AS
	BEGIN
		IF EXISTS (SELECT * from marcas where marca=@marca)
			print 'La marca ya existe'
		ELSE
			BEGIN
				INSERT INTO marcas
			   (marca
			   ,nombre
			   ,activo)
		 VALUES
			   (@marca,
			   @nombre, 
			   @activo)
		
		IF @@error  <> 0
			print 'Hubo un problema! No se pudo insertar la marca.'
		ELSE 
			print 'La marca '+ TRIM(@nombre) + 'se insertó correctamente'
			END
	END

EXEC sp_nuevamarca 'SY', '7Xs','YY'

/*
a) Modificar el SP "sp_insertar_marca" para que utilice los bloques TRY / CATCH en el control de errores, y que además
realice el INSERT como una TRANSACCIÓN de confirmación explícita mediante COMMIT o ROLLBACK. Los mensajes que
debe retornar el procedimiento son los mismos de antes.
b) Ejecutar el procedimiento con parámetros de entrada.

*/


CREATE OR ALTER PROCEDURE sp_nuevamarca
	@marca char(1),
	@nombre char(30),
	@activo char(1)
AS

BEGIN TRY
	BEGIN TRANSACTION
		INSERT INTO marcas
			(marca, nombre, activo)
		VALUES
			(UPPER(@marca),UPPER(@nombre),UPPER(@activo))
		COMMIT TRANSACTION
		
		PRINT 'La marca ' + TRIM(UPPER(@nombre)) + ' se insertó correctamente.'
END TRY

BEGIN CATCH
	IF @@error <> 0
	ROLLBACK TRANSACTION
	print 'Hubo un problema! No se pudo insertar la marca.'
	print 'El error es ' + ERROR_MESSAGE()

END CATCH

/*

EJERCICIO DE APLICACIÓN 1

Desarrolle el SP "sp_ventas_anuales", que genera la tabla "tmp_ventas_anuales" que contiene el total de ventas minoristas por
artículo. La tabla debe tener las columnas ARTICULO, CANTIDAD, IMPORTE. Tenga en cuenta los siguientes puntos:

- Se deben excluir ventas anuladas.
- Se debe tomar para el cálculo del importe CANTIDAD * PRECIO de la tabla VENDET.
	- El procedimiento debe recibir como parámetro de entrada el AÑO, y generar la tabla con las ventas de ese año solamente.
	- Se debe evaluar la existencia de la tabla. Si no existe usar SELECT..INTO, y si existe usar TRUNCATE con INSERT..SELECT.
	- Realizar control de errores, mostrando el mensaje "La tabla fue generada con éxito, se insertaron [n] filas." en caso de
	  éxito, o en caso contrario "Se produjo un error durante la inserción. Contacte con el administrador".

TIP: para evaluar si la tabla existe o no, utilice la función OBJECT_ID([nombre_objeto]), que retorna NULL si un objeto no
existe, o un número entero que identifica al objeto en caso contrario. Ver el ejemplo debajo.

*/

CREATE OR ALTER PROCEDURE sp_ventas_anuales
	@año int
AS
BEGIN
	DECLARE @f int
	IF OBJECT_ID('tmp_ventas_anuales') is NULL
		
		SELECT
			vd.articulo as 'art',
			vd.cantidad as 'cant',
			vd.CANTIDAD * vd.PRECIO as 'Importe',
			vc.fecha
		INTO 
			tmp_ventas_anuales
		FROM
			vendet as vd

			INNER JOIN vencab as vc
			ON vc.letra=vd.letra and vc.factura=vd.factura
		WHERE
			vc.anulada=0 and
			year(vc.fecha)=@año
	ELSE
		BEGIN
			TRUNCATE TABLE 	"tmp_ventas_anuales"
			INSERT INTO tmp_ventas_anuales
			SELECT
				a.articulo,
				vd.cantidad,
				vd.CANTIDAD * vd.PRECIO as 'Importe',
				vc.fecha

			FROM
				vendet as vd
				INNER JOIN articulos as a
				ON vd.articulo=a.articulo
				INNER JOIN vencab as vc
				ON vc.letra=vd.letra and vc.factura=vd.factura
			WHERE
				vc.anulada=0 and
				year(vc.fecha)=@año
		END

		SET @f=@@ROWCOUNT

		IF @@ERROR <> 0
			PRINT 'Se produjo un error durante la inserción. Contacte con el administrador.'
		ELSE
			PRINT 'Se insertaron ' + TRIM(STR(@f)) + ' filas.'
END

EXEC sp_ventas_anuales 2007




/*

EJERCICIO DE APLICACIÓN 2

Desarrolle una nueva versión del SP "sp_ventas_anuales", pero que realice el control de errores utilizando TRY / CATCH,
presentando los mismos mensajes de error.

*/



CREATE OR ALTER PROCEDURE sp_ventas_anuales
	@año int
AS
BEGIN TRY 

	SELECT
			vd.articulo as 'art',
			sum(vd.cantidad) as 'cant',
			sum(vd.CANTIDAD * vd.PRECIO) as 'Importe'
			
		INTO 
			tmp_ventas_anuales
		FROM
			vendet as vd
			INNER JOIN vencab as vc
			ON vc.letra=vd.letra and vc.factura=vd.factura
		WHERE
			vc.anulada=0 and
			year(vc.fecha)=@año
		GROUP BY
			vd.articulo
		PRINT 'Filas incertadas exitosamente'
END TRY
BEGIN CATCH
	IF ERROR_MESSAGE()= 2714
		BEGIN
			TRUNCATE TABLE "tmp_ventas_anuales"
			INSERT INTO tmp_ventas_anuales
			SELECT
				vd.articulo as 'art',
				sum(vd.cantidad) as 'cant',
				sum(vd.CANTIDAD * vd.PRECIO) as 'Importe'

			FROM
				vendet as vd
				INNER JOIN vencab as vc
				ON vc.letra=vd.letra and vc.factura=vd.factura
			WHERE
				vc.anulada=0 and
				year(vc.fecha)=@año
			GROUP BY
				vd.articulo
			PRINT 'Se insertaron filas. BLOQUE CATCH'
		END
	ELSE
		PRINT 'Se produjo un error durante la inserción. Contacte con el administrador.'
END CATCH




DROP TABLE tmp_ventas_anuales

SELECT * FROM tmp_ventas_anuales

