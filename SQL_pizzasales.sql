create database pizzahut;
use pizzahut;
create table orders(
  order_id int not null,
  order_date date not null,
  order_time time not null
 );
 
ALTER TABLE orders
ADD CONSTRAINT PK_order_id PRIMARY KEY (order_id);

drop table order_details;
create table order_details(
  order_details_id int primary key,
  order_id int not null,
  pizza_id text not null,
  quantity int not null
 );
 
 
 -- Retrieve the total numbers of orders placed

SELECT 
    COUNT(order_id)
FROM
    orders;


-- Calculate the total revenue generated from pizza sales.
SELECT 
    SUM(o.quantity * p.price) AS total_sales
FROM
    order_details AS o
        NATURAL JOIN
    pizzas AS p;
    
    
    -- Identify the highest-priced pizza.
SELECT 
    MAX(price)
FROM
    pizzas;
    
    
    -- Identify the most common pizza size ordered.
SELECT 
    size, COUNT(*)
FROM
    pizzas
        NATURAL JOIN
    order_details
GROUP BY size
LIMIT 1; 


-- List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pt.name, SUM(od.quantity)
FROM
    pizza_types AS pt
        JOIN
    pizzas ON pt.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details AS od ON pizzas.pizza_id = od.pizza_id
GROUP BY pt.name
ORDER BY SUM(od.quantity) DESC
LIMIT 5;


-- Join the necessary tables to find the total quantity of each pizza category ordered.
SELECT 
    pt.category, sum(od.quantity) as quantity
FROM
    pizza_types AS pt
        JOIN
    pizzas AS p ON pt.pizza_type_id = p.pizza_type_id
        JOIN
    order_details AS od ON p.pizza_id = od.pizza_id
GROUP BY pt.category
ORDER BY sum(od.quantity) DESC;


-- Determine the distribution of orders by hour of the day.
SELECT 
    HOUR(order_time), COUNT(*)
FROM
    orders
GROUP BY HOUR(order_time)
ORDER BY COUNT(*) DESC;


-- Join relevant tables to find the category-wise distribution of pizzas.
SELECT 
    category, COUNT(name)
FROM
    pizza_types
GROUP BY category;


-- Group the orders by date and calculate the average number of pizzas ordered per day.
SELECT 
    ROUND(AVG(total), 0)
FROM
    (SELECT 
        o.order_date, SUM(od.quantity) AS total
    FROM
        orders AS o
    JOIN order_details AS od ON o.order_id = od.order_id
    GROUP BY o.order_date) AS order_quantity;
    
    
    -- Determine the top 3 most ordered pizza types based on revenue.
SELECT 
    pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;


-- Calculate the percentage contribution of each pizza type to total revenue.
SELECT 
    pizza_types.category,
    ROUND((SUM(order_details.quantity * pizzas.price) / (SELECT 
                    SUM(o.quantity * p.price) AS total_sales
                FROM
                    order_details AS o
                        JOIN
                    pizzas AS p ON p.pizza_id = o.pizza_id)) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;


-- Analyze the cumulative revenue generated over time.
select order_date, round(sum(revenue) over(order by order_date),2) as cum_revenue
from
(select order_date, sum(order_details.quantity*pizzas.price) as revenue from
order_details join pizzas on order_details.pizza_id=pizzas.pizza_id
join orders on orders.order_id=order_details.order_id
group by order_date) as sales;


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

select category,name, revenue from 
(select category, name, revenue,
rank() over(partition by category order by revenue desc) as rn
from
(select pizza_types.category, pizza_types.name, sum(order_details.quantity*pizzas.price) as revenue
from pizza_types join pizzas
on pizzas.pizza_type_id=pizza_types.pizza_type_id
join order_details on order_details.pizza_id= pizzas.pizza_id
group by pizza_types.category, pizza_types.name) as a) as b
where rn<=3 ;    