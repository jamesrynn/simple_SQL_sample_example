-- Number of accounts.
SELECT	COUNT(*)

FROM	master.dbo.Account




-- Number of people that have a purchase balance which rounds down to either 0,10,...90.
SELECT 		FLOOR(A.PurchaseBalance/10)*10,
			COUNT(*)
			
FROM 		master.dbo.Account AS A

WHERE 		A.PurchaseBalance < 100

GROUP BY	FLOOR(A.PurchaseBalance/10)*10




-- Number of accounts for each customer, and amounts owed.
SELECT		C.CustomerId,
			C.FirstName,
			C.LastName,
			COUNT(*) N_Accounts,
			SUM(A.PurchaseBalance) AS Total_Borrowed
		
FROM		Master.dbo.Account AS A
			INNER JOIN Master.dbo.AccountCustomer AS AC	ON A.AccountId = AC.AccountId
			INNER JOIN Master.dbo.Customer AS C		 	ON AC.CustomerId = C.CustomerId
		
GROUP BY	C.CustomerId,
			C.FirstName,
			C.LastName

		
			
			
-- Get portfolio composition by Product name.
SELECT		P.PortfolioName,
			zP.ProductName,
			COUNT(*)

FROM		Master.dbo.Account AS A
			INNER JOIN Master.dbo.Portfolio AS P 		ON A.PortfolioId = P.PortfolioId
			INNER JOIN Master.dbo.zProductType AS zP	ON A.ProductType = zP.ProductType

GROUP BY	P.PortfolioName,
			zP.ProductName

ORDER BY 	1,
			2


			
		
-- Get Customer's collections.
SELECT		C.FirstName,
			C.LastName,
			A.AccountId,
			A.PurchaseBalance,
			SUM(COL.TransactionAmount) AS Collections
		
FROM		Master.dbo.Account AS A
			INNER JOIN Master.dbo.AccountCustomer AS AC	ON A.AccountId = AC.AccountId
			INNER JOIN Master.dbo.Customer AS C 		ON AC.CustomerId = C.CustomerId
			INNER JOIN Master.dbo.Collections AS COL 	ON A.AccountId = COL.AccountId

GROUP BY	C.FirstName,
			C.LastName,
			A.AccountId,
			A.PurchaseBalance

		
	
			
-- How many open accounts does each customer have.
	SELECT	C.FirstName,
			C.LastName,
			SUM(CASE WHEN T.Status = 1 THEN 1 ELSE 0 END) 					AS N_Closed,
			SUM(CASE WHEN T.Status > 0 AND T.Status < 1 THEN 1 ELSE 0 END) 	AS N_Partial,
			COUNT(*) AS N_Total
		
FROM		(
			SELECT		C.CustomerId,
						A.AccountId,
						SUM(COL.TransactionAmount) / A.PurchaseBalance Status
					
			FROM		Master.dbo.Account AS A
						INNER JOIN Master.dbo.AccountCustomer AS AC	ON A.AccountId = AC.AccountId
						INNER JOIN Master.dbo.Customer AS C 		ON AC.CustomerId = C.CustomerId
						INNER JOIN Master.dbo.Collections AS COL 	ON A.AccountId = COL.AccountId
					
			GROUP BY 	C.CustomerId,
						A.AccountId,
						A.PurchaseBalance
			) AS T
			INNER JOIN Master.dbo.Customer AS C ON T.CustomerId = C.CustomerId

GROUP BY	C.FirstName,
			C.LastName

		
	
			
-- Have any Customers settled all accounts?
SELECT		C.FirstName,
			C.LastName,
			SUM(T.Closed) AS N_Closed,
			COUNT(*) AS N_Total
		
FROM		(
			SELECT		C.CustomerId,
						A.AccountId,
						CASE WHEN SUM(COL.TransactionAmount) - A.PurchaseBalance >= 0 THEN 1 ELSE 0 END AS Closed
			
			FROM		Master.dbo.Account AS A
						INNER JOIN Master.dbo.AccountCustomer AS AC	ON A.AccountId = AC.AccountId
						INNER JOIN Master.dbo.Customer AS C 		ON AC.CustomerId = C.CustomerId
						INNER JOIN Master.dbo.Collections AS COL 	ON A.AccountId = COL.AccountId
						
			GROUP BY	C.CustomerId,
						A.AccountId,
						A.PurchaseBalance
			) AS T
			INNER JOIN Master.dbo.Customer C ON T.CustomerId = C.CustomerId
		
GROUP BY 	C.FirstName,
			C.LastName
		
HAVING		SUM(T.Closed) = COUNT(*)