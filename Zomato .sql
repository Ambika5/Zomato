# 1. Find customers who have never ordered ?
SELECT name
FROM users
WHERE user_id NOT IN (SELECT DISTINCT user_id FROM orders);

# 2. Average Price/dish?
select
 f.name,avg(price) as avgprice
 from menu as m
 join food as f
 on m.f_id=f.f_id
 group by f.name;
 
 # 3.Find the top restaurant in terms of the number of orders for a given month?
 SELECT * FROM (SELECT 
ord.r_id,
month(orderdate) as month,
COUNT(*) AS order_count,
dense_rank() over(partition by month(orderdate) order by count(*) desc) as rno
FROM orders ord 
INNER JOIN order_details orddtls ON ord.order_id = orddtls.order_id
GROUP BY month(orderdate),ord.r_id
ORDER BY month) a
WHERE rno = 1 and month = 6;

 
 # 4.restaurants with june monthly sales greater than x for ? x=500
 select r.r_name,sum(amount) as revenue
 from orders as o
 join restaurants as r
 on o.r_id=r.r_id
 where MONTHNAME(orderdate) LIKE 'JUNE'
 Group By r.r_name
 HAVING sum(amount)>500; 
 
 # 5.Show all orders with order details for a 'Aanish' customer in between june and july?
 Select o.order_id, r.r_name, f.name
 from orders as o
 join restaurants as r
 on r.r_id = o.r_id
 join order_details as od
 on od.order_id = o.order_id
 join food as f
 on f.f_id = od.f_id
 where user_id = (select user_id from users where name = "Aanish")
 And (orderdate >'2022=06-10' AND orderdate < '2022-07-10');


#6. Month over month revenue growth of swiggy? 
select month,((revenue - prev)/prev)*100 as totalrevenue  from (
with sales as
  (
    select MONTHNAME(orderdate) as 'month',SUM(amount) as 'revenue'
	from orders
    group by month
    order by month
  )
select month,revenue,LAG(revenue,1) over(order by revenue) as prev from sales
) as t;    


# 7. Find restaurants with max repeated customers ?
SELECT r.r_name, MAX(loyal_customers) as max_loyal_customers
FROM (
    SELECT r_id, user_id, COUNT(*) AS 'loyal_customers'
    FROM orders
    GROUP BY r_id, user_id
    HAVING COUNT(*) > 1
) AS t
JOIN restaurants AS r ON r.r_id = t.r_id
GROUP BY r.r_name
ORDER BY max_loyal_customers DESC
LIMIT 1;
 