/*
Solutions to Part 1 of the Query Tasks.
*/


-- Q1: What is the average balance in each portfolio?
SELECT 		P.PortfolioName,
			AVG(A.PurchaseBalance) 
			
FROM 		Account AS A
			INNER JOIN 	Portfolio as P ON P.PortfolioId = A.PortfolioId 
			
GROUP BY 	P.PortfolioName

ORDER BY 	P.PortfolioName



-- Q2: What is the average balance by Product Type?
SELECT 		A.ProductType,
			AVG(A.PurchaseBalance) 
			
FROM 		Account AS A

GROUP BY 	A.ProductType 

ORDER BY 	A.ProductType



-- Q3: What is the average balance today (hint: discount previous collections from purchase value) of all customers whose surname begins with a G?
SELECT DISTINCT 	Cu.LastName,
					Cu.FirstName,
					AVG(A.PurchaseBalance - Co.TransactionAmount) AS AverageBalance
					
FROM 				Account as A
					INNER JOIN Collections 		AS Co ON Co.AccountId = A.AccountId
					INNER JOIN AccountCustomer 	AS AC ON AC.AccountId = A.AccountId
					INNER JOIN Customer 		AS Cu ON Cu.CustomerId = AC.CustomerId
					
WHERE				Cu.LastName LIKE 'G%'
--WHERE 			SUBSTRING(Cu.LastName,1,1)='G'

GROUP BY 			Cu.LastName,
					Cu.FirstName
					
ORDER BY 			Cu.LastName,
					Cu.FirstName



-- Q4: Which customer has the highest number of accounts?
-- Solution 1: Count the number of accounts each customer has and list them in decreasing order. Read the answer from the top of the table that is returned.
SELECT 		TOP 5
			C.FirstName,
			C.LastName,
			AC.CustomerId,
			COUNT(AC.AccountId) AS NumAcc
			
FROM 		AccountCustomer AS AC
			INNER JOIN Customer AS C ON AC.CustomerId = C.CustomerId 

GROUP BY 	C.FirstName, C.LastName, AC.CustomerId

ORDER BY 	COUNT(AC.AccountId) DESC

	
-- Solution 2: Count the number of accounts each customer has using a subquery and then retrievefrom that the maximum value of the results returned.
-- Note that here we do not return the details of the customer/customers who has/have this number of accounts.
SELECT 	MAX(S.NumAcc) AS MaxNAccounts

FROM 	(
		SELECT 		C.FirstName,
					C.LastName
					AC.CustomerId,
					COUNT(AC.AccountId) AS NumAcc
					
		FROM 		AccountCustomer AS AC
					INNER JOIN Customer AS C ON AC.CustomerId = C.CustomerId 
					
		GROUP BY 	C.FirstName,
					C.LastName,
					AC.CustomerId
		) AS S

	

				

