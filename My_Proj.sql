create database Pizza ;
use Pizza;

-- 1. Loading the data from the csv files
select * from pizzas;

select * from pizza_types ;


create table orders(
order_id int not null primary key,
order_date date not null,
order_time time not null);

select  * from orders;

create table order_details(
order_details_id int not null primary key,
order_id int not null,
pizza_id text not null,
quantity int not null);

select * from order_details;


-- 2 ->Retreive the total number of orders placed
-- select count(*)  from orders;
-- or
SELECT 
    COUNT(order_id) AS Total_Orders
FROM
    orders;

-- 3 -> calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(p.price * od.quantity), 2) AS Total_Revenue
FROM
    pizzas p
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id;
    
    
    
-- 4->    Identify the highest price pizza (with name and price)

SELECT 
    pt.name, p.price AS Price
FROM
    pizzas p
        INNER JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
ORDER BY p.price DESC
LIMIT 1;

-- or by subquery

-- SELECT 
--     pt.name, p.price AS Price
-- FROM
--     pizzas p
--        INNER JOIN
--    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
-- WHERE
--    p.price = (SELECT 
--            MAX(price)
--        FROM
--            pizzas);


-- 5 Identify the most common pizza size ordered.

SELECT 
    size, COUNT(size) as Total
FROM
    pizzas p
        INNER JOIN
    order_details od ON p.pizza_id = od.pizza_id
GROUP BY size
ORDER BY COUNT(size) DESC
LIMIT 1;

-- 6. List the top 5 ordered pizza types along with their quantitites

SELECT
    pt.name as Name , SUM(quantity) as Total_Quantity
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.name
ORDER BY SUM(quantity) DESC
LIMIT 5;

-- 7. Join the necessary tables to find the total quantity
--     of each pizza category ordered

SELECT 
    pt.category as Category , SUM(quantity) as Total_Quantity
FROM
    pizzas p
        JOIN
    pizza_types pt ON p.pizza_type_id = pt.pizza_type_id
        JOIN
    order_details od ON od.pizza_id = p.pizza_id
GROUP BY pt.category
ORDER BY SUM(quantity);


-- 8 Determine the distribution of orders by hour of the day

SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS Orders
FROM
    orders
GROUP BY HOUR(order_time)  
ORDER BY HOUR(order_time);

-- 9 Join releveant tables to find the category-wise
--   distribution of pizzas

select category, count(category)
from pizza_types
group by category;


-- 10 Group the orders by date and calculate the average 
--    number of pizzas order per day

SELECT 
    ROUND(AVG(count1),2) AS Average_Pizza_Ordered_Per_Day
FROM
    (SELECT 
        order_date AS date1, SUM(quantity) AS count1
    FROM
        orders o
    JOIN order_details od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS join_table;



-- 11  Determine the top 3 most ordered pizza(name of the pizza) 
--     types based on revenue

SELECT 
    pt.name AS Pizza_Name,
    SUM(price * quantity) AS Total_Revenue
FROM
    pizzas p
        JOIN
    order_details o ON p.pizza_id = o.pizza_id
        JOIN
    pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
GROUP BY name
ORDER BY SUM(price * quantity) DESC
LIMIT 3;



-- 12 Calculate the percentage contribution of each pizza type(category wise)
--    to total revenue

SELECT 
    Pizza_Category,
    ROUND(Total_Revenue_PerCat, 2) AS Total_Revenue_PerCat,
    CONCAT(ROUND((Total_Revenue_PerCat / Total_Revenue) * 100,
                    2),
            '%') AS Percentage_Per_Category
FROM
    (SELECT 
        pt.category AS Pizza_Category,
            SUM(price * quantity) AS Total_Revenue_PerCat
    FROM
        pizzas p
    JOIN order_details o ON p.pizza_id = o.pizza_id
    JOIN pizza_types pt ON pt.pizza_type_id = p.pizza_type_id
    GROUP BY pt.category) AS j
        CROSS JOIN
    (SELECT 
        SUM(price * quantity) AS Total_Revenue
    FROM
        pizzas p
    JOIN order_details o ON p.pizza_id = o.pizza_id) AS j1;



-- 13 Analyze the cumulative revenue generated over time(Date)

select order_date as Order_Date,sum(revenue) over (order by order_date) as Cumulative_Revenue 
from
(select order_date ,sum(quantity*price) as revenue
from 
pizzas p join order_details od
on p.pizza_id = od.pizza_id
join orders o
on o.order_id =od.order_id
group by order_date) as rev;




-- 14 Determine the top 3 most ordered pizza types based on revenue for each pizza category

select RankNumber ,name ,revenue from
(select category , name , rev as revenue,
rank() over (partition  by category order by rev desc) as RankNumber
from
(select category , name , sum(quantity*price) as rev from
pizzas p join pizza_types pt
on p.pizza_type_id = pt.pizza_type_id
join order_details o on
o.pizza_id = p.pizza_id
group by category , name ) as cte1) as cte2 
where RankNumber <=3;





 





