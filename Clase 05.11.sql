/*

CLASE 05/11

SP CON PARÁMETROS Y CONTROL DE ERRORES

a) Construir el SP "sp_insertar_marca" que permita insertar una nueva marca en la tabla homónima. El procedimiento debe solicitar
como parámetros de entrada los valores de las tres columnas de la tabla. Deberá validarse en él la ocurrencia de errores y
presentar los mensajes "Hubo un problema! No se pudo insertar la marca." en caso de error, o "La marca [nombre] se insertó
correctamente" en caso de éxito. En caso de que la marca a insertar ya exista, mostrar el mensaje "La marca [marca] ya existe".
b) Ejecutar el procedimiento con parámetros de entrada.

*/

-- a)

CREATE OR ALTER PROCEDURE sp_insertar_marca
	@marca char(1),		-- PARÁMETRO DE ENTRADA
	@nombre char(30),	-- PARÁMETRO DE ENTRADA
	@activo char(1)		-- PARÁMETRO DE ENTRADA
AS
BEGIN

	-- VALIDA LA EXISTENCIA DE LA MARCA A INSERTAR

	IF EXISTS (SELECT * FROM marcas WHERE marca = @marca) -- "EXISTS" VALIDA LA EXISTENCIA DE FILAS EN EL RESULTADO DEL SELECT

		PRINT 'La marca ' + TRIM(@marca) + ' ya existe.'
		--GOTO ERRORES

	ELSE 
		BEGIN
			
			-- REALIZA LA INSERCIÓN EN LA TABLA

			INSERT INTO marcas
				(marca, nombre, activo)
			VALUES
				(@marca,@nombre,@activo)

			-- VALIDA LA OCURRENCIA DE ERRORES

			IF @@ERROR <> 0  --- '<>' distinto de 
				PRINT 'Hubo un problema! No se pudo insertar la marca.'
			ELSE
				PRINT 'La marca ' + TRIM(@nombre) + ' se insertó correctamente.'
		END
--ERRORES:
--	PRINT 'La marca ' + TRIM(@marca) + ' ya existe.'

END

-- b)

EXEC sp_insertar_marca 'X','XTREME','N'

EXEC sp_insertar_marca 'w','Wrangler','s'

DELETE FROM marcas WHERE marca IN ('W','X')

INSERT INTO marcas VALUES ('W','WRANGLER','S')

SELECT * FROM marcas -- CONSULTA DE COMPROBACIÓN

/*

VARIANTE SP CON TRY/CATCH Y USO DE TRANSACCIONES

/*
Este bloque son dos bloques, uno inicia con BEGIN TRY y finaliza con END TRY
El segundo BEGIN CATCH y finaliza con END CATCH 
Estos bloques lo que hacen es comenzar a ejecutar el bloque try (cant de instrucciones indeterminada).
Si hay un error en el bloque try en un principio; lo que este hace es abortar y finalizar la ejecucion. Luego le pasa el control al bloque CATCH
Si ninguna de las instrucciones del bloque TRY da error, entonces el bloque try comienza y finaliza; por lo que nunca entre por el bloque CATCH el procedimiento
Ejecuto el procedimiento almacenado, luego esto pasa al bloque try ejecutando cada una de las intruscciones y si no hay falla, lo finaliza. Si hay, pasa al otro bloque
*/

a) Modificar el SP "sp_insertar_marca" para que utilice los bloques TRY / CATCH en el control de errores, y que además
realice el INSERT como una TRANSACCIÓN de confirmación explícita mediante COMMIT o ROLLBACK. Los mensajes que
debe retornar el procedimiento son los mismos de antes.
b) Ejecutar el procedimiento con parámetros de entrada.

*/

-- a)

CREATE OR ALTER PROCEDURE sp_insertar_marca
	@marca char(1), 
	@nombre char(30),
	@activo char(1)
AS

BEGIN TRY

	BEGIN TRANSACTION -- INICIA UNA TRANSACCIÓN DE CONFIRMACIÓN EXPLÍCITA CON "COMMIT" O "ROLLBACK"

		-- INTENTA REALIZAR LA INSERCIÓN EN LA TABLA

		INSERT INTO marcas
			(marca, nombre, activo)
		VALUES
			(UPPER(@marca),UPPER(@nombre),UPPER(@activo))

		-- SI INSERTA SIN ERRORES, REALIZA LA CONFIRMACIÓN DE LA TRANSACCION; CASO CONTRARIO SALTA AL BLOQUE "CATCH"

		COMMIT TRANSACTION -- CONFIRMA LA INSERCIÓN

		PRINT 'La marca ' + TRIM(UPPER(@nombre)) + ' se insertó correctamente.'

END TRY

BEGIN CATCH  -- Aca lo esta usando para corroborar errores
	
	ROLLBACK TRANSACTION -- VUELVE ATRÁS LA INSERCIÓN

	IF ERROR_NUMBER() = 2627 -- EL ERROR 2627 ES DE CLAVE DUPLICADA (YA EXISTE LA MARCA)
		PRINT 'La marca ' + TRIM(UPPER(@marca)) + ' ya existe.' -- El error es: ' + ERROR_MESSAGE()
	ELSE
		PRINT 'Hubo un problema! No se pudo insertar la marca.'
	
END CATCH

-- b)

EXEC sp_insertar_marca 'X','XTREME','S'

SELECT * FROM marcas -- CONSULTA DE COMPROBACIÓN

DELETE marcas WHERE marca IN ('W','w','X') -- ELIMINA LAS FILAS INSERTADAS EN LA TABLA MARCAS

INSERT INTO marcas VALUES ('W','WRANGLER','S')

SELECT @@TRANCOUNT

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

USE Ventas2

SELECT OBJECT_ID('marcas') -- TABLA QUE EXISTE

/* 
La funcion OBJECT_ID ercibe como argumento el nombre de un objeto y si existe nos devuelve un numero, el cual es un identificador unico de ese opbjeto dentro del mundo del metadato. Sino es nulo
si el resultado es nulo, ese objeto no existe en mi DB, ergo puedo crearlo libremente
*/

SELECT OBJECT_ID('proveedores') -- TABLA QUE NO EXISTE

SELECT
	vd.articulo AS "Artículo",
	SUM(vd.cantidad) AS "Cantidad",
	SUM(vd.cantidad * vd.precio) AS "Importe"
INTO
	tmp_ventas_anuales
FROM
	vencab AS vc
	INNER JOIN vendet AS vd
	ON vc.letra = vd.letra AND vc.factura = vd.factura
WHERE
	vc.anulada = 0
	AND YEAR(vc.fecha) = 2008
GROUP BY
	vd.articulo

CREATE OR ALTER PROCEDURE sp_ventas_anuales
	@año int
AS
BEGIN
	DECLARE @f int
	--
	IF OBJECT_ID('tmp_ventas_anuales') IS NULL
		SELECT
			vd.articulo AS "Artículo",
			SUM(vd.cantidad) AS "Cantidad",
			SUM(vd.cantidad * vd.precio) AS "Importe"
		INTO
			tmp_ventas_anuales
		FROM
			vencab AS vc
			INNER JOIN vendet AS vd
			ON vc.letra = vd.letra AND vc.factura = vd.factura
		WHERE
			vc.anulada = 0
			AND YEAR(vc.fecha) = @año
		GROUP BY
			vd.articulo
	ELSE
		BEGIN
			TRUNCATE TABLE tmp_ventas_anuales
			--
			INSERT INTO tmp_ventas_anuales
			SELECT
				vd.articulo AS "Artículo",
				SUM(vd.cantidad) AS "Cantidad",
				SUM(vd.cantidad * vd.precio) AS "Importe"
			FROM
				vencab AS vc
				INNER JOIN vendet AS vd
				ON vc.letra = vd.letra AND vc.factura = vd.factura
			WHERE
				vc.anulada = 0
				AND YEAR(vc.fecha) = @año
			GROUP BY
				vd.articulo	
		END
		--
		SET @f = @@ROWCOUNT
		--
		IF @@ERROR <> 0
			PRINT 'Se produjo un error durante la inserción. Contacte con el administrador.'
		ELSE
			PRINT 'Se insertaron ' + TRIM(STR(@f)) + ' filas.'
END

EXEC sp_ventas_anuales 2009

DROP TABLE tmp_ventas_anuales

SELECT * FROM tmp_ventas_anuales


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
		vd.articulo AS "Artículo",
		SUM(vd.cantidad) AS "Cantidad",
		SUM(vd.cantidad * vd.precio) AS "Importe"
	INTO
		tmp_ventas_anuales
	FROM
		vencab AS vc
		INNER JOIN vendet AS vd
		ON vc.letra = vd.letra AND vc.factura = vd.factura
	WHERE
		vc.anulada = 0
		AND YEAR(vc.fecha) = @año
	GROUP BY
		vd.articulo
	--
	PRINT 'Se insertaron ' + TRIM(STR(@@ROWCOUNT)) + ' filas. BLOQUE TRY'
END TRY

BEGIN CATCH	
	IF ERROR_NUMBER() = 2714
		BEGIN
			TRUNCATE TABLE tmp_ventas_anuales
			--
			INSERT INTO tmp_ventas_anuales
			SELECT
				vd.articulo AS "Artículo",
				SUM(vd.cantidad) AS "Cantidad",
				SUM(vd.cantidad * vd.precio) AS "Importe"
			FROM
				vencab AS vc
				INNER JOIN vendet AS vd
				ON vc.letra = vd.letra AND vc.factura = vd.factura
			WHERE
				vc.anulada = 0
				AND YEAR(vc.fecha) = @año
			GROUP BY
				vd.articulo
			--
			PRINT 'Se insertaron ' + TRIM(STR(@@ROWCOUNT)) + ' filas. BLOQUE CATCH'
		END
	ELSE
		PRINT 'Se produjo un error durante la inserción. Contacte con el administrador.'
END CATCH


EXEC sp_ventas_anuales 2004

SELECT count(*) from sys.tables where name = 'tmp_ventas_anuales'

/*
Resolucion de un select, creacion de vista o hacer una insercion o modificacion de datos y proc almacinado.
*/