
 /*
 join all the required five tables
 FY, FQ are adjusted based on MS's fiscal year
 left outer join are used to retain all the sales records
 reusult is stored into #all_related_tables
 */
 SELECT CASE WHEN DATEPART(month,OrderDate) >=7 then DATEPART(year, DATEADD(year, 1, OrderDate)) else DATEPART(year, OrderDate) END FY, 
 DATEPART(quarter, DATEADD(quarter, 2, OrderDate)) as FQ,
 Sales.SalesOrderHeader.OrderDate, Sales.SalesOrderHeader.SalesOrderID, Sales.SalesOrderDetail.ProductID,
 Production.Product.ProductSubcategoryID, Production.ProductSubcategory.ProductCategoryID, Production.ProductCategory.Name,
 Sales.SalesOrderHeader.OnlineOrderFlag as OnlineOrder
 into #all_related_tables
 FROM Sales.SalesOrderHeader 
 left outer JOIN Sales.SalesOrderDetail ON Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID
 left outer JOIN Production.Product ON Sales.SalesOrderDetail.ProductID = Production.Product.ProductID
 left outer JOIN Production.ProductSubcategory ON Production.Product.ProductSubcategoryID = Production.ProductSubcategory.ProductSubcategoryID
 left outer JOIN Production.ProductCategory ON Production.ProductSubcategory.ProductcategoryID = Production.ProductCategory.ProductcategoryID
 order by OrderDate

 /*
 select all the columns required for part 1 ans
 SalesOrderIDs are kept for checking if a particular order has the correct values inside FY, FQ, Bikes, Accessories,
 Clothing, Components, OfflineOrders, and OnlineOrders
 max(case when..then..else..end) are used instead of pivoting, to return product categories columns
 all the case statements will run through a single row in the #all_related_tables and return 0 or 1
 then the max() function return 0 if a particular group of item is not sold,
 and return 1 if the item(s) is sold, even if more than one item is sold
 result is stored in #Salesdetail 
 */
 SELECT SalesOrderID, avg(FY) as FY, avg(FQ) as FQ
    ,MAX(CASE WHEN Name = 'Bikes' THEN '1' ELSE '0' END) [Bikes]
    ,MAX(CASE WHEN Name = 'Accessories' THEN '1' ELSE '0' END) [Accessories] 
    ,MAX(CASE WHEN Name = 'Clothing' THEN '1' ELSE '0' END) [Clothing]
    ,MAX(CASE WHEN Name = 'Components' THEN '1' ELSE '0' END) [Components]
	,MAX(CASE WHEN OnlineOrder = '1' THEN '0' ELSE '1' END) [OfflineOrders]
	,MAX(CASE WHEN OnlineOrder = '1' THEN '1' ELSE '0' END) [OnlineOrders]
	into #Salesdetail
FROM #all_related_tables
GROUP BY SalesOrderID
order by FY, FQ

/*
SalesOrderID is de-selected after checking
group by FY, FQ to return data in year and quarter format
group by Bikes, Accessories, Clothing, Components to return all possible combinations of sold items
set FY between 2012 and 2014 as the SalesOrderHeader table have 2011 Q4 data which is not for our analysis purpose
sum the offlineOrders and OnlineOrders with [cast () as int] functions as the 0/1 value may be string
result is stored in #part1temp
*/
select FY, FQ, Bikes, Accessories,Clothing, Components, 
sum(cast([OfflineOrders] as int)) as OfflineOrders, sum(cast([OnlineOrders] as int)) as OnlineOrders
into #part1temp
from #Salesdetail
where FY Between 2012 and 2014
group by FY,FQ,Bikes,Accessories,Clothing,Components
order by FY,FQ,Bikes,Accessories,Clothing,Components

/*run the following codes to obtain part 1 ans*/
select * from #part1temp
order by FY,FQ,Bikes,Accessories,Clothing,Components
/*end of part 1 ans*/


/*
calculate percentages of offline orders and online orders with respect to its corresponding FY and FQ, therefore, using partition by FY, FQ
use 100.0 insted of 100 for the calculation, as the values in offlineorders and onlineorders are all integers
after that, cast the value to decimal with 5 digits, in which 2 digits are behind the decimal place
*/
select *,
cast(100.0*OfflineOrders/sum(OfflineOrders) over(partition by FY, FQ)  as decimal (5,2)) as [Percentage of Offline Orders],
cast(100.0*OnlineOrders/sum(OnlineOrders) over(partition by FY, FQ) as decimal (5,2)) as [Percentage of Online Orders]
into #part2step
from #part1temp
order by FY,FQ,Bikes,Accessories,Clothing,Components

/*
select all required columns from #part2step, except for [Percentage of Offline Orders] and [Percentage of Offline Orders]
concat the percentage value with '%', and put the two columns back to our desired output
*/

/*run the following codes to obtain part 2 ans*/
select FY,FQ,Bikes,Accessories,Clothing,Components, OfflineOrders, OnlineOrders,
CONCAT("Percentage of Offline Orders",'%') as "Percentage of Offline Orders", 
CONCAT("Percentage of Online Orders",'%') as "Percentage of Online Orders"
from #part2step
order by FY,FQ,Bikes,Accessories,Clothing,Components
/*end of part 2 ans*/
