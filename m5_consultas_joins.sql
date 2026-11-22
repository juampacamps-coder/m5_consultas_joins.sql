
--CONSULTA 1 — Vista base del proyecto

--Proposito:obtener una vista general de tablas que resuma la informacion mas importante, facilitando su posterior uso en Power BI.

SELECT 
ventas.fecha_venta, 
clientes.id_cliente,
ciudad,
categorias.descripcion,
nombre_categoria,
ventas.cantidad,
ventas.precio_unitario,
(ventas.cantidad*ventas.precio_unitario) AS total_venta
FROM ventas
INNER JOIN clientes ON ventas.id_cliente = clientes.id_cliente
INNER JOIN productos ON ventas.id_producto = productos.id_producto
INNER JOIN categorias ON categorias.id_categoria = productos.id_categoria

--Hallazgo: Computacion es la categoria que mas facturacion genera (tambien productos mas caros). 
--Cordoba solo vende accesorios y Mendoza solo Audio y almacenamiento.



--CONSULTA 2 — Clientes sin ventas

--Proposito: hallar clientes que nunca compraron, para su posterior analisis en las areas correspondientes.

SELECT clientes.nombre, clientes.email, clientes.fecha_registro
FROM clientes
LEFT JOIN ventas ON clientes.id_cliente = ventas.id_cliente
WHERE ventas.id_venta IS NULL

SELECT COUNT(*)
FROM clientes
LEFT JOIN ventas ON clientes.id_cliente = ventas.id_cliente
WHERE ventas.id_venta IS NULL

--Hallazgo: no existen clientes que no hayan comprado, lo cual es un buen indicio. Se ha añadido el count debajo para mayor seguridad y control en la consulta.



--CONSULTA 3 — Productos sin ventas 

--Proposito: detectar cuales son los productos que no han tenido ventas, para su evaluacion de desempeño. 

SELECT productos.nombre_producto, productos.id_categoria, ventas.precio_unitario 
FROM productos
LEFT JOIN ventas ON productos.id_producto = ventas.id_producto
WHERE ventas.id_venta IS NULL

SELECT COUNT(*)
FROM productos
LEFT JOIN ventas ON productos.id_producto = ventas.id_producto
WHERE ventas.id_venta IS NULL

--Hallazgo: todos los productos han tenido al menos una venta minima. Se ha añadido el count debajo para mayor seguridad y control en la consulta.



--CONSULTA 4 — Consolidado por canal --

--Proposito: luego de aplicado un criterio, se quiere averiguar el nivel de facturacion que tuvo cada lote para compararlos. 

SELECT PERIODO_VENTA, sum(TOTAL_VENTA) AS TOTAL_PERIODO
FROM  
		(
SELECT cantidad*precio_unitario AS TOTAL_VENTA, fecha_venta, cantidad, 'Primer periodo' AS PERIODO_VENTA
FROM ventas
WHERE fecha_venta < '2024-03-10'
UNION ALL
SELECT cantidad*precio_unitario AS TOTAL_VENTA, fecha_venta, cantidad, 'Segundo periodo' AS PERIODO_VENTA
FROM ventas
WHERE fecha_venta >= '2024-03-10'
		) AS consolidado

GROUP BY PERIODO_VENTA

--Hallazgo: el primer periodo obtuvo una minima superioridad de facturacion que el segundo, tan solo 16 euros. 
--Lo destacable es que el primero tiene 2 dias menos de operaciones (del 05 al 08) y eso que el segundo tiene la venta individual de mayor importe (1200).
--En resumen, mayores ventas no se traduce en mayor facturacion.