--- Total sales 
select sum(unitprice*quantity)
from NW_orderdetails

---Total quantity sold
select sum(quantity)
from NW_orderdetails

---Total Transactions
select count(orderID) as Total_Transactions
from NW_orderdetails

--- Top 10 Customers by Sales
with cte_sales as(
	select c.customerID, c.contactName, c.country, city, CONVERT(date, orderDate) orderdate, CONVERT(date, shippedDate) shpippeddate, np.productName, od.unitPrice, od.quantity
	from NW_customers as c
	join NW_orders as o
	on c.customerID = o.customerID
	join NW_orderdetails as od
	on o.orderID = od.orderID
	join NW_products as np
	on od.productID =np.productID)

select top 10 customerID, contactName, country, sum(unitPrice*quantity) as sales 
from cte_sales
group by customerID, country, contactName
order by 4 desc

--- Breakdown of Purchase by customer and date
with cte_CustPurchase as(
	select c.customerID, c.contactName, city, CONVERT(date, orderDate) orderdate, MONTH(orderdate) as mth, YEAR(orderdate) as YR, CONVERT(date, shippedDate) shpippeddate, np.productName, od.unitPrice, od.quantity,
	(od.unitPrice * od.quantity) as sales
	from NW_customers as c
	join NW_orders as o
	on c.customerID = o.customerID
	join NW_orderdetails as od
	on o.orderID = od.orderID
	join NW_products as np
	on od.productID =np.productID)
	
select contactName, productName, orderdate, sales,
sum(sales) over (partition by contactname order by sales, orderdate) as purchase
from cte_CustPurchase
where yr in (2013,2014)
order by 3 asc

with cte_CustPurchase as(
	select c.customerID, c.contactName, city, CONVERT(date, orderDate) orderdate, MONTH(orderdate) as mth, YEAR(orderdate) as YR, CONVERT(date, shippedDate) shpippeddate, np.productName, od.unitPrice, od.quantity,
	(od.unitPrice * od.quantity) as sales
	from NW_customers as c
	join NW_orders as o
	on c.customerID = o.customerID
	join NW_orderdetails as od
	on o.orderID = od.orderID
	join NW_products as np
	on od.productID =np.productID)
	
select contactName, productName, orderdate, sales,
sum(sales) over (partition by contactname order by sales, orderdate) as purchase
from cte_CustPurchase
where yr in (2014,2015)

--- top 10 Products by Sales
with cte_products as(
	select c.customerID, c.contactName, city, CONVERT(date, orderDate) orderdate, CONVERT(date, shippedDate) shpippeddate, np.productName, od.unitPrice, od.quantity
	from NW_customers as c
	join NW_orders as o
	on c.customerID = o.customerID
	join NW_orderdetails as od
	on o.orderID = od.orderID
	join NW_products as np
	on od.productID =np.productID)

select top 10 productName, sum(unitPrice*quantity) as sales 
from cte_products
group by productName
order by 2 Desc

---Top 10 Most Ordered Products
with cte_products as(
	select c.customerID, c.contactName, city, CONVERT(date, orderDate) orderdate, CONVERT(date, shippedDate) shpippeddate, np.productName, od.unitPrice, od.quantity
	from NW_customers as c
	join NW_orders as o
	on c.customerID = o.customerID
	join NW_orderdetails as od
	on o.orderID = od.orderID
	join NW_products as np
	on od.productID =np.productID)

select top 10 productName, sum(quantity) as Qty
from cte_products
group by productName
order by 2 Desc

--- Product Category by Sales 
with cte_category as(
	select productName, categoryName ,(od.unitPrice*od.quantity) as sales
	from NW_orders as o
	join NW_orderdetails as od
	on o.orderID = od.orderID
	join NW_products as np
	on od.productID =np.productID
	join NW_categories as c
	on np.categoryID = c.categoryID)

select categoryName, sum(sales) sales_cat
from cte_category
group by categoryName
order by 2 desc

--- Most Ordered Categories
with cte_category as(
	select productName, categoryName ,od.unitPrice, od.quantity
	from NW_orders as o
	join NW_orderdetails as od
	on o.orderID = od.orderID
	join NW_products as np
	on od.productID =np.productID
	join NW_categories as c
	on np.categoryID = c.categoryID)

select categoryName, sum(quantity) sales_cat
from cte_category
group by categoryName
order by 2 desc

--- Breakdown of Products and Categories by Sales and Quantity
select p.productName, categoryname, sum(od.quantity*od.unitprice) as sales, sum(od.quantity) as Qty
from NW_products as p 
join NW_categories as c
on p.categoryID = c.categoryID
join NW_orderdetails as od
on od.productID = p.productID
group by p.productName, categoryName
order by 2,4 desc


--- Total Sales per Month across all Year
with cte_MonthSales as(
	select c.customerID, c.contactName, city, CONVERT(date, orderDate) orderdate, format(orderdate, 'MMMM') as mth, month(orderDate) as mt, YEAR(orderdate) as YR, CONVERT(date, shippedDate) shpippeddate, np.productName, od.unitPrice, od.quantity
	from NW_customers as c
	join NW_orders as o
	on c.customerID = o.customerID
	join NW_orderdetails as od
	on o.orderID = od.orderID
	join NW_products as np
	on od.productID =np.productID)
	
select  Mt, Mth, sum(unitPrice*quantity) as sales 
from cte_MonthSales
group by mth, mt
order by 1 asc

--- Total Sales Per Year
with cte_YearSales as(
	select c.customerID, c.contactName, city, CONVERT(date, orderDate) orderdate, MONTH(orderdate) as mth, YEAR(orderdate) as YR, CONVERT(date, shippedDate) shpippeddate, np.productName, od.unitPrice, od.quantity
	from NW_customers as c
	join NW_orders as o
	on c.customerID = o.customerID
	join NW_orderdetails as od
	on o.orderID = od.orderID
	join NW_products as np
	on od.productID =np.productID)
	
select YR, sum(unitPrice*quantity) as sales 
from cte_YearSales
group by YR
order by  2 desc

--- Percentage Contribution of each product category to total sales
with cte_percent as(
	select categoryName,(od.unitPrice*od.quantity) as sales
	from NW_orders as o
	join NW_orderdetails as od
	on o.orderID = od.orderID
	join NW_products as np
	on od.productID =np.productID
	join NW_categories as c
	on np.categoryID = c.categoryID)

select categoryName, round((sum(sales)/(select sum(unitprice*quantity)
                                 from NW_orderdetails))*100, 2) as percent_contribution
from cte_percent
group by categoryName
order by 2 desc

--- shipping of orders and freight charges
select productName, np.quantityPerUnit, od.unitPrice, od.quantity ,companyName,  freight
from NW_orders as o
join NW_shippers as s
on o.shipperID = s.shipperID
join NW_orderdetails as od
on o.orderID = od.orderID
join NW_products as np
on od.productID = np.productID
order by 2,5,4

--- Most used Shipping Company and Average Freight Cost
select companyName, COUNT(companyName) as Most_Used, round(AVG(freight),2) as Avg_Freight
from NW_orders as o
join NW_shippers as s
on o.shipperID = s.shipperID
group by companyName
order by 2 desc

---Employee sales and number of transactions handled
select employeeName, title,count(o.orderID) as Transactions_Handled ,sum(od.unitprice*quantity) as Sales
from NW_orders as o
join NW_employees as e
on o.employeeID = e.employeeID
join NW_orderdetails as od
on od.orderID = o.orderID
group by employeeName, title
order by 4 Desc

--- Breakdown of Employees Sales Perfomance acorss all Years
with cte_employees as(
select employeeName, title, year(orderdate) as Yr, sum(od.unitPrice*od.quantity) as sales
from NW_orders as o
join NW_employees as e
on o.employeeID = e.employeeID
join NW_orderdetails as od
on od.orderID = o.orderID
group by employeeName, title, orderDate)

select*,
case
	when sum_sales > lag(sum_sales) over (partition by employeeName order by yr) then 'Increased'
	when sum_sales < lag(sum_sales) over (partition by employeeName order by yr) then 'Dropped'
	when sum_sales = lag(sum_sales) over (partition by employeeName order by yr) then 'Equal'
	else 'START_YEAR'
end Flag
from(
	select distinct(EmployeeName), Title, Yr, sum(sales) as Sum_sales
	from cte_employees
	group by employeeName, title, Yr
	) as x


select *
from NW_orders as o
join NW_employees as e
on o.employeeID = e.employeeID
join NW_orderdetails as od
on od.orderID = o.orderID

