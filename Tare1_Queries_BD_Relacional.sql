

# Queries para Tarea #1 - Base de Datos Relacionales: 


# Las 5 ciudades con las mayores ventas.

 SELECT City, SUM(Total) AS total_ventas
  FROM salesDB.supermarket_sales
  GROUP BY City
  ORDER BY total_ventas DESC
  LIMIT 5
  
# Para cada una de estas ciudades, los 2 productos más vendidos
  
  WITH TopCiudades AS (
  SELECT City, SUM(Total) AS total_ventas
  FROM salesDB.supermarket_sales
  GROUP BY City
  ORDER BY total_ventas DESC
  LIMIT 5
)
, ProductosVentas AS (
  SELECT
    City,
    ProductLine ,
    Sum(Quantity) as cantidad,
    ROW_NUMBER() OVER (PARTITION BY City ORDER BY Sum(Quantity) DESC) AS rn
    FROM salesDB.supermarket_sales
    group by City, ProductLine
)
SELECT TC.City, PV.ProductLine, PV.cantidad
FROM TopCiudades TC
INNER JOIN ProductosVentas PV ON TC.City = PV.City
WHERE PV.rn <= 2
ORDER BY TC.City, PV.rn;

# Para cada combinación de ciudad y producto, el método de pago más frecuente y la cantidad de transacciones realizadas con ese método.

WITH MetodoPagoFrecuente AS (
  SELECT
    City,
    ProductLine,
    Payment,
    COUNT(*) AS cantidad_transacciones,
    RANK() OVER (PARTITION BY City, ProductLine ORDER BY COUNT(*) DESC) AS ranking
  FROM salesDB.supermarket_sales ss 
  GROUP BY City , ProductLine , Payment
)
SELECT City, ProductLine, Payment, cantidad_transacciones
FROM MetodoPagoFrecuente
WHERE ranking = 1;