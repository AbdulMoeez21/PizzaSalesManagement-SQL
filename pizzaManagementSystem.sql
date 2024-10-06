create database pizzaManagementSystem

use pizzaManagementSystem


select * from orders,order_details

select * from pizzas,pizza_types
select * from pizza_types


--TABLE 
--pizzas        (columns - pizza_id,pizza_type_id,size,price)
--pizza_types   (columns - pizza_type_id,name,category,ingredients)
--order         (columns - order_id,order_date, order_time)
--order_details (columns - order_details_id,order_id, pizza_id,quantity)


--Basic:
--Retrieve the total number of orders placed.

select count(order_id) as Total_Orders
from orders

--Calculate the total revenue generated from pizza sales.

select round(sum(p.price*od.quantity),2) as Total_Revenue 
from pizzas as p
left join order_details as od on p.pizza_id=od.pizza_id


--Identify the highest-priced pizza.


select top 1 pizza_type_id  as Pizza_Type_Id,max(price) as Highest_Priced
from pizzas
group by  pizza_type_id




--Identify the most common pizza size ordered.

select p.size,count(od.order_details_id) as Most_Common
from order_details as od
left join pizzas as p on od.pizza_id=p.pizza_id 
group by p.size
order by count(od.order_details_id) desc;


--List the top 5 most ordered pizza types along with their quantities.

select distinct top 5 pt.name,sum(od.quantity) as Most_Pizza_Order
from pizza_types as pt
inner join pizzas as p on pt.pizza_type_id=p.pizza_type_id

 join order_details as od on od.pizza_id=p.pizza_id

 group by pt.name
 order by Most_Pizza_Order desc




--Intermediate:
--Join the necessary tables to find the total quantity of each pizza category ordered.
select  pt.category ,count(od.quantity) as Total_Quantity
from pizza_types as pt
inner join pizzas as p on pt.pizza_type_id=p.pizza_type_id

 join order_details as od on od.pizza_id=p.pizza_id

 group by pt.category

 order by Total_Quantity desc;


--Determine the distribution of orders by hour of the day.

select DATEPART(HOUR,order_time) AS Order_Hours ,count(order_id) as Order_Count 
from orders
group by DATEPART(HOUR, order_time)
order by Order_Hours;



--Join relevant tables to find the category-wise distribution of pizzas.

select pt.category , count(od.order_details_id) as Pizza_Count
from order_details as od

join pizzas as p on od.pizza_id=p.pizza_id
join pizza_types as pt on p.pizza_type_id=pt.pizza_type_id
group by pt.category
order by Pizza_Count desc ;





--Group the orders by date and calculate the average number of pizzas ordered per day.
with daily_pizzas_count as(
select o.order_date,
sum(od.quantity) as Total_Pizzas_Ordered

from  orders as o
join order_details as od on o.order_id=od.order_id
group by o.order_date


 )
 select avg(Total_Pizzas_Ordered) as Avg_Pizzas_Per_Day
 from daily_pizzas_count
 


--Determine the top 3 most ordered pizza types based on revenue.
select top 3 pt.name,round(sum(p.price*od.quantity),2) as Total_Revenue 
from pizzas as p
 join order_details as od on p.pizza_id=od.pizza_id
join pizza_types as pt on p.pizza_type_id=pt.pizza_type_id
 group by pt.name
 order by Total_Revenue desc




--Advanced:
--Calculate the percentage contribution of each pizza type to total revenue.
/*
formula:
			(category revenue/total revenue) * 100 as percentage of each pizza type
*/

--Total_Revenue
select round(sum(p.price*od.quantity),2) as Total_Revenue 
from pizzas as p
left join order_details as od on p.pizza_id=od.pizza_id


--Category_Revenue
select pt.category ,round(sum(p.price*od.quantity),2) as Category_Revenue 
from pizzas as p
 join order_details as od on p.pizza_id=od.pizza_id
join pizza_types as pt on p.pizza_type_id=pt.pizza_type_id
 group by pt.category
 order by Category_Revenue desc



 --Main Query
select  pt.category,
sum(p.price*od.quantity) as Category_Revenue,

(sum(p.price*od.quantity) /(select round(sum(p.price*od.quantity),2) as Total_Revenue 
from pizzas as p
left join order_details as od on p.pizza_id=od.pizza_id))*100 as Revenue_in_Percentage
from pizzas as p
 join order_details as od on p.pizza_id=od.pizza_id
join pizza_types as pt on p.pizza_type_id=pt.pizza_type_id
 group by pt.category
 order by Revenue_in_Percentage desc



 --Chat gpt
 SELECT  
    pt.category,
    SUM(p.price * od.quantity) AS Category_Revenue,
    (SUM(p.price * od.quantity) / (SELECT ROUND(SUM(p.price * od.quantity), 2) 
                                     FROM pizzas AS p
                                     LEFT JOIN order_details AS od ON p.pizza_id = od.pizza_id)) * 100 AS Revenue_in_Percentage
FROM 
    pizzas AS p
JOIN 
    order_details AS od ON p.pizza_id = od.pizza_id
JOIN 
    pizza_types AS pt ON p.pizza_type_id = pt.pizza_type_id
GROUP BY 
    pt.category
ORDER BY 
    Revenue_in_Percentage DESC;

--Analyze the cumulative revenue generated over time.
--cte

with cum_Revenue as (select o.order_date,
sum(od.quantity*p.price) as Daily_revenue
from order_details as od
join pizzas as p on od.pizza_id=p.pizza_id

join orders as o on o.order_id=od.order_id

group by o.order_date) 

select order_date,
Daily_revenue,
--window function
sum(Daily_Revenue) over(order by order_date) as Cumulative_Revenue
from cum_Revenue



--Determine the top 3 most ordered pizza types based on revenue for each pizza category.





