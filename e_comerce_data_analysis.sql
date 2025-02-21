select * from aisles;
select * from departments;
select * from products;
select * from orders;
select * from order_product;

--Create a temporary table that joins the orders,
--order_products, and products tables to get
--information about each order, including 
--the products that were purchased and their
--department and aisle information.
create temporary table order_info as 
select o.order_id, o.user_id, o.order_number,o.order_dow,
o.order_hour_of_day, o.days_since_prior_order,
op.product_id,op.add_to_cart_order, op.reordered
from orders as o
join order_product as op on o.order_id = op.order_id
join products as p on op.product_id = p.product_id;

select * from order_info;


CREATE TEMPORARY TABLE product_order AS 
SELECT product_id, 
       COUNT(*) AS total_orders,
       COUNT(CASE WHEN reordered = 1 THEN 1 ELSE NULL END) AS total_reorders,
       AVG(add_to_cart_order) AS avg_add_to_cart
FROM order_info
GROUP BY product_id;

select * from product_order;



create temporary table department_order as 
select department_id , count(*) as 
total_products_purchased,
count(DISTINCT product_id) as total_unique_products_purchased,
count(case when order_dow < 6 then 1 else null end) as total_weekday_purchase,
count(case when order_dow >= 6 then 1 else null end)as
total_weekend_purchase,
avg(order_hour_of_day) as avg_order_time
from order_info
group by department_id;


DROP TABLE IF EXISTS department_order;

CREATE TEMPORARY TABLE department_order AS 
SELECT p.department_id, 
       COUNT(*) AS total_products_purchased,
       COUNT(DISTINCT oi.product_id) AS total_unique_products_purchased,
       COUNT(CASE WHEN oi.order_dow < 6 THEN 1 ELSE NULL END) AS total_weekday_purchase,
       COUNT(CASE WHEN oi.order_dow >= 6 THEN 1 ELSE NULL END) AS total_weekend_purchase,
       AVG(oi.order_hour_of_day) AS avg_order_time
FROM order_info oi
JOIN products p ON oi.product_id = p.product_id
GROUP BY p.department_id;

select * from department_order;







DROP TABLE IF EXISTS aisle_order;

CREATE TEMPORARY TABLE aisle_order AS
SELECT a.aisle_id, 
       COUNT(*) AS total_products_purchased,
       COUNT(DISTINCT oi.product_id) AS total_unique_products_purchased
FROM order_info oi
JOIN products p ON oi.product_id = p.product_id
JOIN aisles a ON p.aisle_id = a.aisle_id
GROUP BY a.aisle_id
ORDER BY COUNT(*) DESC
LIMIT 10;

select * from aisle_order;


create temporary table product_bheaviour_analysis as
select pi.product_id,pi.product_name,
pi.department_id,
d.department,pi.aisle_id,a.aisle,pos.total_orders,
pos.total_reorders,pos.avg_add_to_cart,

dos.total_products_purchased,
dos.total_unique_products_purchased,
dos.total_weekday_purchase,
dos.avg_order_time
 from product_order as pos 
 join products as pi on 
 pos.product_id = pi.product_id

join departments as d on 
pi.department_id = d.department_id
join aisles as a on 
pi.aisle_id = a.aisle_id
join department_order  as dos on pi.department_id = dos.department_id;

select * from product_bheaviour_analysis;