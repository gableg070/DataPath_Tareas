
-- Creación de Procedimiento Almacenado

CREATE PROCEDURE GenerarMetricas()
BEGIN
    -- 1. Ciudad con el mayor número total de ventas
	with topCiudades as  (
	Select 
	City, SUM(Total) as ventas
	From supermarket_sales 
	group by City
	order by ventas desc
	limit 1 
	), 
	
	topProductos as (
		select ProductLine, Sum(Quantity) as total from supermarket_sales
		where city = (Select city from topCiudades)
		group by 1
		order by total DESC 
		limit 1
	), 
	
	topPago as (
	select Payment,
    COUNT(*) AS cantidad_transacciones
    from supermarket_sales
    where city = (Select city from topCiudades)
	group by 1
	order by cantidad_transacciones DESC 
	limit 1
	)
		
    -- 2. Producto más vendido en la ciudad con más ventas + 3. El método de pago más común para las transacciones en esa ciudad
    SELECT tc.City, tp.ProductLine , t.Payment INTO @ciudad_max_ventas, @producto_mas_vendido, @pago_frecuente FROM topCiudades tc , topProductos tp, topPago t;
   
	   
    -- 4. Promedio de calificación de los clientes en esa ciudad
    SELECT AVG(rating) INTO @promedio_calificacion
    FROM supermarket_sales
    WHERE City = @ciudad_max_ventas;
    
   
    -- 5. Crear una vista con las 5 transacciones con los totales más altos en esa ciudad
      CREATE or REPLACE VIEW Top5Transacciones AS
			SELECT v.`Invoice ID` , v.City , v.ProductLine, v.Payment , v.Rating , v.Total 
			FROM supermarket_sales v
			JOIN (
			    SELECT City , SUM(Total) AS total_ventas
			    FROM supermarket_sales
			    GROUP BY City
			    ORDER BY total_ventas DESC
			    LIMIT 1
			) subq
			ON v.City = subq.City	
			ORDER BY v.Total DESC
			LIMIT 5;
	
    
    -- Generar la tabla de Métricas
    CREATE TEMPORARY TABLE Metricas (
        ciudad VARCHAR(50),
        producto_mas_vendido VARCHAR(50),
        metodo_pago_mas_comun VARCHAR(50),
        promedio_calificacion DECIMAL(4, 2)
    );
    
    INSERT INTO Metricas (ciudad, producto_mas_vendido, metodo_pago_mas_comun, promedio_calificacion)
    VALUES (@ciudad_max_ventas, @producto_mas_vendido, @pago_frecuente, @promedio_calificacion);
    
    SELECT * FROM Metricas;

    SELECT * FROM Top5Transacciones;
    
    DROP View Top5Transacciones;
    
END;

-- Crear Evento para ejecutar el Procedimiento Almacenado para todos los días a la 1:00 PM
CREATE EVENT GenerarMetricasEvento
ON SCHEDULE EVERY 1 DAY
STARTS TIMESTAMP(CURRENT_DATE, '13:00:00')
DO
BEGIN
    CALL GenerarMetricas();
END;
