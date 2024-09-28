--- EDA apple sales datasets 1m
select * from category
select * from products
select * from sales
select * from stores
select * from warranty 
--- ET 5.418 AFTER INDEX IN SALES(PRODUCT_ID)
--- et 3.717 after index in sales(store_id)
select distinct(repair_status) from warranty 
EXPLAIN ANALYZE
SELECT * FROM SALES
WHERE PRODUCT_ID = 'P-44'  

EXPLAIN ANALYZE
SELECT * FROM SALES
WHERE STORE_ID = 'ST-31'

CREATE INDEX SALES_PRODUCT_ID ON SALES(PRODUCT_ID) 
CREATE INDEX SALES_STORES_ID ON SALES(STORE_ID) 
create index sales_dates on sales(sale_date) 

--- bussiness problems

--1.Find each country and number of stores 

select 
	  country,
     count(store_id) as no_of_stores
from stores
group by country 
order by 2 desc 

---2. What is the total number of units sold by each store? 
select * from stores
select  * from sales 
select 
	s.store_id,
	s.store_name,
	sum(s1.quantity) as total_units
from stores as s
join
sales as s1
on s1.store_id = s.store_id 
group by s.store_id,2 
order by 3 desc
select * FROM SALES
--3. How many sales occurred in December 2023? 
select 
   count(sale_id) as total_sales,
extract(year from sale_date) as yearly,
extract(month from sale_date) as monthly
from sales 
where extract(year from sale_date) = '2023'
and  extract(month from sale_date) = '12' 
group by 2,3 
 
--4. How many stores have never had a warranty claim filed against any of their products? 
select count(*) from stores
where store_id not in(	
	select distinct(store_id)
from sales as s
right join 
warranty as w
on w.sale_id = s.sale_id
) 

--5. What percentage of warranty claims are marked as "Warranty Void"? 
select count(claim_id)/(select count(*) from warranty)::numeric  * 100 as warranty_claims
	from warranty
where repair_status = 'Warranty Void' 

--6. Which store had the highest total units sold in the last year? 
select * from stores 
select * from sales 
select s.store_id,
	   s.store_name,
	   sum(quantity) as total_units, 
	   extract(year from s1.sale_date) as year
from stores as s
join
sales as s1
on s1.store_id = s.store_id  
where extract(year from s1.sale_date) = 2022 
group by 1,2,4
order by 3 desc
limit 1


--7. Count the number of unique products sold in the last year. 
 
select count(distinct(p.product_id)) as total_products
from products as p
right join
sales as s
on s.product_id = p.product_id 
where extract(year from sale_date) = 2023 

--8. What is the average price of products in each category? 
select * from category
select AVG(p.price) as avg_price_product,
       p.category_id,
       p.product_name,
	   c.category_name
from products as p
join
category as c 
on c.category_id = p.category_id
group by 2,3,4 
order by 1 desc 

--9. How many warranty claims were filed in 2020? 
select * from warranty
select count(distinct (claim_id)) as total_claim_warranty
from warranty
where extract(year from claim_date) = 2020  


--10. Identify each store and best selling day based on highest qty sold  
select  
* 
from
(
select 
  store_id,
  to_char(sale_date,'day') as days,
  sum(quantity) as total_quantity,
  rank()over(partition by store_id order by sum(quantity)  desc ) as rankly
from sales
group by 1,2 
) as t1
where rankly = 1 

select * from sales
Medium to Hard (5 Questions)
---11. Identify least selling product of each country for each year based on total unit sold  
select *
from
(
select p.product_name,
	   s1.country,
	   sum(s.quantity) as total_quantity,
	  (rank()over(partition by s1.country order by sum(s.quantity) asc)) as drn
	from sales as s 
join
stores as s1
on s.store_id = s1.store_id
join
products as p
on s.product_id = p.product_id 
group by 1,2
)
where drn = 1

---12. How many warranty claims were filed within 180 days of a product sale? 
select w.* from warranty as w
join
sales as s
on w.sale_id = s.sale_id 
where w.claim_date - s.sale_date  >= 180 


--14. List the months in the last 3 years where sales exceeded 5000 units from usa. 
SELECT * FROM SALES 
select * from stores
select 
	 to_char(sale_date,'MM-YYYY') AS MONTHLY, 
	 SUM(s.quantity) as total_sales
	from sales as s
join
stores as s1
on s.store_id = s1.store_id
join
products as p
on s.product_id = p.product_id 
where s.sale_date >= current_date - interval '3years' 
and country = 'USA' 
group by 1
having sum(quantity)>= 5000 

--15  Which product category had the most warranty claims filed in the last 2 years? 
select 
	 p.product_name,
	 count(w.claim_id) as total
from warranty as w
left join
sales as s
on w.sale_id = s.sale_id
join
products as p
on p.product_id = s.product_id
join
category as c
on p.category_id = c.category_id 
where w.claim_date >= current_date - interval '2years'
group by 1

---16. Determine the percentage chance of receiving claims after each purchase for each country. 
select 
	  total_sales,
	  total_claims,
	  country,
	  coalesce(total_claims::numeric/total_sales::numeric * 100,'0') as risks 
from
(select s1.country,
	   sum(s.quantity) as total_sales,
	   count(w.claim_id) as total_claims
	from sales as s
join
stores as s1
on s.store_id = s1.store_id
left join
warranty as w
on s.sale_id = w.sale_id 
group by 1
) as t1 
order by 4 desc 

---17. Analyze each stores year by year growth ratio 
with yearly_sales 
as
(select s1.store_id,
	   s1.store_name,
	   sum(price * quantity) as total_sales,
	   s1.country,
	   extract(year from s.sale_date) as year
	from sales as s
join
stores as s1
on s.store_id = s1.store_id 
join
products as p
on s.product_id = p.product_id 
group by 1,2,4,5 
order by 5,3 
),
 growth_ratio
as
(
select 
     store_name,
     total_sales as current_year_sales,
     year,
	 lag(total_sales, 1)over(partition by store_name order by year) as last_year_sale
from yearly_sales
)
select
   store_name,
   last_year_sale,
   current_year_sales,
   (current_year_sales - last_year_sale)::numeric/last_year_sale * 100
from growth_ratio 


--18. What is the correlation between product price and warranty claims for products sold in the
--last five years? (Segment based on diff price) 

select 
	 count(claim_id) as total_warranty_claims,
	 case when p.price < 500 then 'less_expensive_product'
	      when p.price between 500 and 1000 then 'mid_range_product'
	      else 'expensive_product'
	 end as price_segment
	from warranty as w
left join
sales as s
on w.sale_id = s.sale_id
join
products as p
on p.product_id = s.product_id
where claim_date >= current_date - interval '5years'
group by price_segment 

---19. Identify the store with the highest percentage of "Paid Repaired" claims in relation to total
--claims filed. 
select * from warranty
with paid_repairs
as
(
select s.store_id,
	   count(w.claim_id) as paid_claims
from sales as s
right join
warranty as w
on s.sale_id = w.sale_id
where w.repair_status = 'Paid Repaired'
group by 1
),
total_paid_repairs
as
(select s.store_id,
	   count(w.claim_id) as total_paid_repairs
from sales as s
right join
warranty as w
on s.sale_id = w.sale_id
where w.repair_status = 'Paid Repaired'
group by 1)

select 
    tr.store_id,
    pr.paid_repairs,
    tr.total_paid_repairs 
from paid_repairs as pr 
join
total_paid_repairs as tr
on pr.store_id = tr.store_id

---20.Write SQL query to calculate the monthly running total of sales for each store over the past
--four years and compare the trends across this period?
with total_sales_revenue
as
(
select s1.store_id,
	  sum(price * quantity) as total_revenue,
	  extract(year from s.sale_date) as year,
	  extract(month from s.sale_date) as monthly
	from sales as s
join
stores as s1
on s.store_id = s1.store_id
join
products as p
on s.product_id = p.product_id 
group by 1,3,4 
) 
select 
	store_id,
    year,
    monthly,
    total_revenue,
	sum(total_revenue) over(partition by store_id order by year,monthly) as running_total
from total_sales_revenue 

--21.Analyze sales trends of product over time, segmented into key time periods: from launch to 6
--months, 6-12 months, 12-18 months, and beyond 18 months? 

select 
	   p.product_name,
	   sum(s.quantity) as total_revenue,
	   case 
	       when s.sale_date between p.launch_date and p.launch_date + interval '6months' then '6-months'
	       when s.sale_date between p.launch_date and p.launch_date + interval '12 months' then'6-12months'
	       else'18months'
	   end as plc
	from sales as s	
join
products as p
on s.product_id = p.product_id
group by 1 ,3
order by 2 desc