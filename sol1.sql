/*
-- answers
SELECT P.PortfolioName, count(*)
FROM master.dbo.Portfolio AS P
	INNER JOIN master.dbo.Account as A ON
GROUP BY P.PortfolioName 
*/


-- Q1: Avergae balance in each portfolio.
SELECT P.PortfolioName, AVG(A.PurchaseBalance) 
FROM Account AS A
	INNER JOIN Portfolio as P ON P.PortfolioId = A.PortfolioId 
GROUP BY P.PortfolioName
ORDER BY P.PortfolioName


-- Q2: Average balance by Product Type.
SELECT A.ProductType, AVG(A.PurchaseBalance) 
FROM Account AS A
GROUP BY A.ProductType 
ORDER BY A.ProductType


-- Q3: 
SELECT DISTINCT Cu.LastName, Cu.FirstName, AVG(A.PurchaseBalance - Co.TransactionAmount)
FROM Account as A
	INNER JOIN Collections as Co ON Co.AccountId = A.AccountId
	INNER JOIN AccountCustomer as AC ON AC.AccountId = A.AccountId
		INNER JOIN Customer AS Cu ON Cu.CustomerId = AC.CustomerId
WHERE SUBSTRING(Cu.LastName,1,1)='G'
GROUP BY Cu.LastName, Cu.FirstName
ORDER BY Cu.LastName, Cu.FirstName


-- Q4: VERSION 1
-- Count number of accounts each customer has and list them in decreasing order.
SELECT TOP 5 C.FirstName, C.LastName, AC.CustomerId, COUNT(AC.AccountId) AS NumAcc
FROM AccountCustomer AS AC
	INNER JOIN Customer AS C ON AC.CustomerId = C.CustomerId 
GROUP BY C.FirstName, C.LastName, AC.CustomerId
ORDER BY COUNT(AC.AccountId) DESC

	
-- Q4: VERSION 2
-- Find maximum value of the count of the number of accounts each customer has using a subquery.
SELECT MAX(S.NumAcc) AS MaxNAccounts
FROM (
	SELECT C.FirstName, C.LastName, AC.CustomerId, COUNT(AC.AccountId) AS NumAcc
	FROM AccountCustomer AS AC
		INNER JOIN Customer AS C ON AC.CustomerId = C.CustomerId 
	GROUP BY C.FirstName, C.LastName, AC.CustomerId) AS S

	

				

