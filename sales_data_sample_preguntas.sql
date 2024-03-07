-- Exploramos los datos 
SELECT *
FROM sales_data_sample
ORDER BY STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i') DESC;


-- Cuánto han vendido el último mes por día?  Los vendidos (status shipped, in process and resolved)
-- How much have they sold in the last month per day? (status shipped, in process and resolved)
-- SELECT DISTINCT status FROM sales_data_sample;
SELECT 
    SALES, 
    ORDERDATE, 
    SUM(SALES) AS TOTAL_SALES
FROM 
    sales_data_sample
WHERE 
    STATUS IN ("Shipped", "In process", "Resolved")
    AND DATE_FORMAT(STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i'), '%Y-%m') = '2005-05'
GROUP BY
    SALES, ORDERDATE
ORDER BY 
    STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i') DESC;
    
    
    
-- Total de ventas del último mes (status shipped, in process and resolved)
-- Total sales in the last month (status shipped, in process and resolved)
SELECT 
    DATE_FORMAT(STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i'), '%Y-%m') AS MonthYear,
    SUM(SALES) AS TOTAL_SALES
FROM 
    sales_data_sample
WHERE 
    STATUS IN ("Shipped","In process", "Resolved")
    AND DATE_FORMAT(STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i'), '%Y-%m') = '2005-05'
GROUP BY
    MonthYear
ORDER BY 
    MonthYear DESC;



-- Quienes son los 5 clientes que más compran y que % de las ventas totales representan (status shipped, in process and resolved)
-- Asumimos que el ordernumber es también el id del comprador ya que tienen el mismo CONTACTFIRSTNAME (
-- Who are the top 5 buying customers and what % of total sales do they represent? (status shipped, in process and resolved)
-- We assume that the ordernumber is also the id of the buyer as they have the same CONTACTFIRSTNAME
-- SELECT DISTINCT ORDERNUMBER FROM sales_data_sample;
SELECT 
    CONTACTFIRSTNAME,
    ORDERNUMBER, 
    SUM(SALES) AS Ventas_por_cliente,
    (SELECT SUM(SALES) FROM sales_data_sample WHERE STATUS IN ("Shipped", "In process", "Resolved")) AS Ventas_totales,
    (SUM(SALES) / (SELECT SUM(SALES) FROM sales_data_sample WHERE STATUS IN ("Shipped", "In process", "Resolved"))) * 100 AS Porcentaje_del_total
FROM 
    sales_data_sample
WHERE 
    STATUS IN ("Shipped", "In process", "Resolved")
GROUP BY 
    CONTACTFIRSTNAME, ORDERNUMBER
ORDER BY 
    Ventas_por_cliente DESC
LIMIT 5;

-- Con los anteriores 5 clientes, obtener el porcentaje total del negocio que suponen entre los 5
-- With the above 5 customers, obtain the total percentage of the business accounted for by the 5 customers.
SELECT 
    SUM(Porcentaje_del_total) AS Suma_Total_Porcentaje
FROM (
    SELECT 
        CONTACTFIRSTNAME,
        ORDERNUMBER, 
        SUM(SALES) AS Ventas_por_cliente,
        (SUM(SALES) / (SELECT SUM(SALES) FROM sales_data_sample WHERE STATUS IN ("Shipped", "In process", "Resolved"))) * 100 AS Porcentaje_del_total
    FROM 
        sales_data_sample
    WHERE 
        STATUS IN ("Shipped", "In process", "Resolved")
    GROUP BY 
        CONTACTFIRSTNAME, ORDERNUMBER
    ORDER BY 
        Ventas_por_cliente DESC
    LIMIT 5
) AS Subconsulta;



-- Cuáles son los 20 productos más caros?
-- What are the 20 most expensive products?
SELECT
    PRODUCTCODE,
    PRICEEACH,
    CUSTOMERNAME, 
    PRODUCTLINE
FROM (
    SELECT
        PRODUCTCODE,
        PRICEEACH,
        CUSTOMERNAME, 
        PRODUCTLINE,
        RANK() OVER (PARTITION BY PRODUCTCODE ORDER BY PRICEEACH DESC) AS rank_num
    FROM
        sales_data_sample
) AS ranked_products
WHERE
    rank_num <= 20;
-- Vemos como hay muchos productos que cuestan 100 y con un mismo productcode pero distinto customername
-- We see how there are many products costing 100 and with the same productcode but different customername



-- Cuáles son los 15 productos más vendidos (Ignoramos status, sino sería añadir where cómo en la primera)
-- What are the top 15 best-selling products (Ignore status, otherwise it would be added where as in the first one)
SELECT 
	PRODUCTCODE,
    CUSTOMERNAME,
    SUM(QUANTITYORDERED) AS Total_QUANTITYORDERED
FROM 
	sales_data_sample
GROUP BY
	QUANTITYORDERED,
    PRODUCTCODE,
    CUSTOMERNAME
ORDER BY 
	Total_QUANTITYORDERED DESC
LIMIT 15;



-- De los anteriores 15 productos, qué ingresos le reportan?
-- Of the above 15 products, what income do they bring you?
SELECT 
	PRODUCTCODE,
    CUSTOMERNAME,
    SUM(QUANTITYORDERED) AS Total_QUANTITYORDERED,
    SUM(SALES) AS Total_SALES
    
FROM 
	sales_data_sample
GROUP BY
    PRODUCTCODE,
    CUSTOMERNAME
    
ORDER BY 
	Total_QUANTITYORDERED DESC
LIMIT 15;



-- Qué cantidad de producto veden de media?
-- How much product do they sell on average?
SELECT AVG(QUANTITYORDERED) AS AVG_QUANTITYORDERED
FROM 
	sales_data_sample;


-- Cuáles son las ciudades a la que más venden? Ordenadas de mayor a menor?
-- Which cities do they sell to the most? Ordered from highest to lowest?
SELECT 
    CITY,
    ROUND(SUM(SALES), 2) AS CITY_TOTAL_SALES
FROM 
    sales_data_sample
GROUP BY 
    CITY
ORDER BY 
    CITY_TOTAL_SALES DESC;



-- Cuáles son los 3 meses que más venden en el último año?
-- What are the top 3 selling months in the last year?
SELECT 
    YEAR(STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i')) AS ORDER_YEAR,
    MONTH(STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i')) AS ORDER_MONTH,
    SUM(SALES) AS TOTAL_SALES
FROM 
    sales_data_sample
WHERE 
    YEAR(STR_TO_DATE(ORDERDATE, '%m/%d/%Y %H:%i')) = 2005
GROUP BY
    ORDER_YEAR, ORDER_MONTH
ORDER BY 
    TOTAL_SALES DESC
LIMIT 3;