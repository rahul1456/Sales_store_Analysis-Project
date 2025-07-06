CREATE TABLE sales_store (
transaction_id VARCHAR(15),
customer_id VARCHAR(15),
customer_name VARCHAR(30),
customer_age INT,
gender VARCHAR(15),
product_id VARCHAR(15),
product_name VARCHAR(15),
product_category VARCHAR(15),
quantiy INT,
prce FLOAT,
payment_mode VARCHAR(15),
purchase_date DATE,
time_of_purchase TIME,
status VARCHAR(15)
);

SELECT * FROM sales_store

SET DATEFORMAT dmy
BULK INSERT sales_store
FROM 'D:\Power BI practice\SQL Sales_Store\sales.csv'
	WITH (
		FIRSTROW=2,
		FIELDTERMINATOR=',',
		ROWTERMINATOR='\n'
	);

	select * from sales_store

	select * into sales from sales_store


	select * from sales_store
	select * from sales


	


select * from sales

---- data cleaning ---
	--- step 1 to find duplicate 

	SELECT transaction_id
FROM sales 
GROUP BY transaction_id
HAVING COUNT(transaction_id) >1

WITH CTE AS (
SELECT *,
	ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS Row_Num
FROM sales
)
--- DELETE FROM CTE
---- WHERE Row_Num=2

SELECT * FROM CTE
WHERE transaction_id IN ('TXN240646','TXN342128','TXN855235','TXN981773','TXN981773','TXN832908')

--- step 2 correction of headers ----

EXEC sp_rename'sales.quantiy','quantity','COLUMN'

EXEC sp_rename'sales.prce','price','COLUMN'


---- step 3 :) TO check Data type 

select column_name, DATA_TYPE
from INFORMATION_SCHEMA.COLUMNS
where TABLE_NAME='sales'


--- step 4 :) To check the Null values 

DECLARE @SQL NVARCHAR(MAX) = '';

SELECT @SQL = STRING_AGG(
    'SELECT ''' + COLUMN_NAME + ''' AS ColumnName, 
    COUNT(*) AS NullCount 
    FROM ' + QUOTENAME(TABLE_SCHEMA) + '.sales 
    WHERE ' + QUOTENAME(COLUMN_NAME) + ' IS NULL', 
    ' UNION ALL '
)
WITHIN GROUP (ORDER BY COLUMN_NAME)
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'sales';

-- Execute the dynamic SQL
EXEC sp_executesql @SQL;


---- Treating Null Value ---

SELECT *
FROM sales 
WHERE transaction_id IS NULL
OR
customer_id IS NULL
OR
customer_name IS NULL
OR
customer_age IS NULL
OR
gender IS NULL
OR
product_id IS NULL
OR
product_name IS NULL
OR
product_category IS NULL
OR
quantity IS NULL
or
payment_mode is null
or
purchase_date is null
or 
status is null
or 
price is null

DELETE FROM sales 
WHERE  transaction_id IS NULL

select * from sales
where customer_name='Ehsaan Ram'
 
update sales
set customer_id='CUST9494'
where transaction_id = 'TXN977900'


select * from sales
where customer_name='Damini Raju'
 
 update sales
 set customer_id ='CUST1401'
 where transaction_id ='TXN985663'


 select * from sales
 where customer_id = 'CUST1003'

 update sales
 set customer_name='Mahika Saini',customer_age='35',gender='Male'
 where transaction_id='TXN432798'
   

select * from sales

--- Data cleaning in Gender --

select Distinct gender
from sales

update sales
set gender='M'
where gender='Male'

update sales
set gender='F'
where gender='Female'

select * from sales

---- Clean Payment Mode ---

select Distinct payment_mode
from sales

update sales
set payment_mode='Credit Card'
Where payment_mode ='CC'


----- Now Data  Analysis & solve the Buisness scenario Question ----

🔥 1. What are the top 5 most selling products by quantity?


 select top 5 product_name, sum(quantity) AS total_Quantity_sold
 from sales
 where status ='delivered'
 group by product_name
 order by total_Quantity_sold DESC

 
--Business Problem:) We don't know which products are most in demand.

--Business Impact: Helps prioritize stock and boost sales through targeted promotions.

--📉 2. Which products are most frequently cancelled

select top 5 product_name, count(*) As total_cancelled
from sales
where status= 'cancelled'
group by product_name
order by total_cancelled DESC

--Business Problem:) Frequent  cancellation affect the revenu, business and customer trust also.
--Business Impact: )  Identify the poor-performing products to improve quality or remove from catalog.


--🕒 3. What time of the day has the highest number of purchases?

select * from sales

select 
      case
	       when DATEPART(HOUR, time_of_purchase) Between 0 and 5 then 'Night'
		   when DATEPART(HOUR, time_of_purchase) Between 6 and 11 then 'Morning'
		   when DATEPART(HOUR, time_of_purchase) Between 12 and 17 then'Afternoon'
		   when DATEPART(HOUR, time_of_purchase) Between 18 and 23 then 'evening'

		   END As time_of_day,
		   count(*) As total_orders
		   from sales
		   group by
		  
		  case
	       when DATEPART(HOUR, time_of_purchase) Between 0 and 5 then 'Night'
		   when DATEPART(HOUR, time_of_purchase) Between 6 and 11 then 'Morning'
		   when DATEPART(HOUR, time_of_purchase) Between 12 and 17 then 'Afternoon'
		   when DATEPART(HOUR, time_of_purchase) Between 18 and 23 then 'evening'

		   END
		   order by total_orders DESC
		   
------Business Problem:)  Find peak sales times.
 --Business Impact:) Optimize staffing, promotions, and server loads.


 
--👥 4. Who are the top 5 highest spending customers?

select * from sales

SELECT TOP 5 customer_name,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS total_spend
FROM sales 
GROUP BY customer_name
ORDER BY SUM(price*quantity) DESC

---- Business Problem Solved : Identify VIP customers.
 ----- Business Impact : Personalized offers, loyalty rewards, and retention---

 
 ---- 5. which product categories generate the highest revenue

 select * from sales 

 select product_category,
 FORMAT(SUM(price*quantity),'C0','en-IN') AS revenue
 from sales
 group by product_category
 order by SUM(price*quantity) DESC



 ------Business Problem solved:) Identify the top-performing product categories.

 --Business Impact:)     Refine product strategy, supply chain, and promotions.
                       --allowing the business to invest more in high-margin 
					   or high-demand categories.

	
--🔄 6. What is the return/cancellation rate per product category?


    select * from sales
  
  ---- cancellation

select product_Category,
       format(count(CASE When status='cancelled' then 1 END)*100.0/COUNT(*),'N3')+' %' AS cancelled_percent
	   from sales
	   group by product_Category
	   order by cancelled_percent DESC


	    ---- return

select product_Category,
       format(count(CASE When status='returned' then 1 END)*100.0/COUNT(*),'N3')+' %' AS returned_percent
	   from sales
	   group by product_Category
	   order by returned_percent DESC


-Business Problem Solved:)   Monitor dissatisfaction trends per category.


---Business Impact: ) Reduce returns, improve product descriptions/expectations.
--                     Helps identify and fix product or logistics issues.


--💳 7. What is the most preferred payment mode?


select * from sales


select payment_mode,count(payment_mode) as total_count
      from sales
	   group by payment_mode
	   order by total_count  DESC


--Business Problem Solved:) Know which payment options customers prefer.

--Business Impact:)       Streamline payment processing, prioritize popular modes.


--🧓 8. How does age group affect purchasing behavior?

select * from sales
--- select min(customer_age) ,Max(customer_age)
         ---  from sales
        
		SELECT 
	CASE	
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END AS customer_age,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS total_purchase
FROM sales 
GROUP BY CASE	
		WHEN customer_age BETWEEN 18 AND 25 THEN '18-25'
		WHEN customer_age BETWEEN 26 AND 35 THEN '26-35'
		WHEN customer_age BETWEEN 36 AND 50 THEN '36-50'
		ELSE '51+'
	END
ORDER BY SUM(price*quantity) DESC


--Business Problem Solved:) Understand customer demographics.

--Business Impact:)          Targeted marketing and product recommendations by age group.


--🔁 9. What’s the monthly sales trend?


       select * from sales

	   ----  Method no 1 ---
SELECT 
	FORMAT(purchase_date,'yyyy-MM') AS Month_Year,
	FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
	SUM(quantity) AS total_quantity
FROM sales 
GROUP BY FORMAT(purchase_date,'yyyy-MM')


----- Method 2 ----

select * from sales

SELECT * FROM sales
	
	SELECT 
		--YEAR(purchase_date) AS Years,
		MONTH(purchase_date) AS Months,
		FORMAT(SUM(price*quantity),'C0','en-IN') AS total_sales,
		SUM(quantity) AS total_quantity
FROM sales
GROUP BY MONTH(purchase_date)
ORDER BY Months


--Business Problem:) Sales fluctuations go unnoticed.


--Business Impact:) Plan inventory and marketing according to seasonal trends.

select * from sales


--🔎 10. Are certain genders buying more specific product categories?



select * from sales

  --Method 1
SELECT gender,product_category,COUNT(product_category) AS total_purchase
FROM sales
GROUP BY gender,product_category
ORDER BY gender

--Method 2
SELECT * FROM sales
	
SELECT * 
FROM ( 
	SELECT gender,product_category
	FROM sales 
	) AS source_table
PIVOT (
	COUNT(gender)
	FOR gender IN ([M],[F])
	) AS pivot_table
ORDER BY product_category


--Business Problem Solved: Gender-based product preferences.

--Business Impact: Personalized ads, gender-focused campaigns.