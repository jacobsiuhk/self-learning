/*join tables demo*/
select * from Sales.SalesOrderHeader
left outer join Sales.SalesOrderDetail
on Sales.SalesOrderHeader.SalesOrderID = Sales.SalesOrderDetail.SalesOrderID

/* last order's bought items information*/
SELECT
SalesOrderID , productid,
unitprice , OrderQty
FROM
Sales.SalesOrderDetail
WHERE
SalesOrderID =
(SELECT MAX(
SalesOrderID ) as lastorder
FROM Sales.SalesOrderHeader)

/* TID from 1 to 5 means the sales are from US, show US's order info in SalesOrderHeader*/
SELECT *
FROM
Sales.SalesOrderHeader
WHERE [TerritoryID] IN (SELECT
TerritoryID FROM Sales.SalesTerritory
WHERE CountryRegionCode ='US')

/*Common Table Expressions demo, eg. similar to defining functions*/
WITH /*begin of function, this function is to return orderdate to year, and find the customerID with respect to the salesorder*/
CTE_year(OrderYear , CustID)
AS
(SELECT YEAR(orderdate), CustomerID
FROM Sales.SalesOrderHeader)  /*end of function*/
SELECT
OrderYear , COUNT(DISTINCT CustID ) AS Cust_Count
FROM CTE_year GROUP BY orderyear 

/*Same result as above, by creating temporary variables)*/
SELECT YEAR(orderdate) as OrderYear, CustomerID as CustID
INTO #Sales FROM
Sales.SalesOrderHeader;
SELECT
OrderYear , COUNT(DISTINCT CustID) AS Cust_Count
FROM #Sales
GROUP BY
OrderYear

/*pivot table example*/
SELECT SalesOrderID, [716] as bicycle ,isnull([777],0) as car,[778],OrderQty  FROM Sales.SalesOrderDetail
PIVOT(avg(UnitPrice) FOR [ProductID] IN([716], [777], [778])) AS PivotTable
WHERE [716] IS NOT NULL or [777] IS NOT NULL or [778] IS NOT NULL;

select GETDATE(); /*current date and time*/
select CURRENT_TIMESTAMP; /*same as above*/
select GETUTCDATE()		 /*UTC+0 date&time*/									  
SELECT DATEPART(year, '2017/08/25')
SELECT DATEPART(month, '2017/08/25')
SELECT DATEPART(day, '2017/08/25')
SELECT DATEPART(WEEKDAY, '2017/08/25')
SELECT DATEPART(WEEK, '2017/08/25')
SELECT DATEPART(quarter, '2017/8/25')
SELECT CAST(getdate() AS DATE) AS [ current_date ] /*CAST function can help you to convert date types to text*/
SELECT CAST(25.65 AS int); /*Convert a value to an int datatype*/
SELECT DATEADD(quarter, 2, '20190912'); /*adding year, quarter, month, week, day, hour, minute, or second*/
SELECT DATEDIFF(month, '20190912', '20200212');/*difference in year, quarter, month, week, day, hour, minute, or second*/
SELECT substring('cpsiu@connect.ust.hk',1,5) /*but account names are of different lengths*/
SELECT CHARINDEX('@', 'cpsiu@connect.ust.hk') /*find the index of @*/
SELECT LEFT('cpsiu@connect.ust.hk', CHARINDEX('@', 'cpsiu@connect.ust.hk') - 1) /*CHARINDEX('@', 'cpsiu@connect.ust.hk')=6,6-1=5, select left 5 char)*/
SELECT RIGHT('cpsiu@connect.ust.hk', len('cpsiu@connect.ust.hk')-CHARINDEX('@', 'cpsiu@connect.ust.hk'))
SELECT LEFT('abcdefg', 5)
SELECT RIGHT('abcdefg', 5)
SELECT REVERSE('abcdefg')
SELECT FORMAT (122, '00000') /*adding leading zeros*/

/*convert a numerical values(MakeFlag) to understandable words*/
SELECT ProductID, Name,
CASE
MakeFlag WHEN 0 THEN 'Product is purchased'
WHEN 1 THEN 'Product is made in house'
ELSE 'Exception' END AS [Made/Purchase]
FROM
Production.Product

/*for marketing analysis, divide sales amount into different groups*/
SELECT
SalesOrderID, CustomerID, SubTotal,
CASE WHEN SubTotal < 10000.00 THEN 'Less than 10000'
WHEN SubTotal BETWEEN 10000.00 AND 30000.00 THEN 'Between 10000 and 30000'
WHEN SubTotal > 30000.00 THEN 'More than 30000'
ELSE 'Unknown' END AS [value] FROM Sales.SalesOrderHeader;

/*AdventureWorks Database is a Microsoft product sample for an online transaction processing (OLTP) database*/

/*Group by TerritoryID then observe the no. of total orders, and to observe no. of online and offline sales*/
SELECT TerritoryID, TotalOrders = COUNT(*),
SUM (CASE WHEN OnlineOrderFlag = 1 THEN 1 ELSE 0 END) AS OnlineSales,
SUM (CASE WHEN OnlineOrderFlag = 0 THEN 1 ELSE 0 END) AS OfflineSales
FROM Sales.SalesOrderHeader GROUP BY TerritoryID ORDER BY TerritoryID
