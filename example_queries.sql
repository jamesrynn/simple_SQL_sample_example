-- Number of accounts.
SELECT	count(*)
FROM	master.dbo.Account


-- Number of people that have a purchase balance which rounds down to either 0,10,...90.
SELECT floor(A.PurchaseBalance/10)*10, count(*)
FROM master.dbo.Account as A
WHERE A.PurchaseBalance < 100
GROUP BY floor(A.PurchaseBalance/10)*10


-- Number of accounts for each customer, and amounts owed.
SELECT	C.CustomerId,
		C.FirstName,
		C.LastName,
		COUNT(*) N_Accounts,
		sum(A.PurchaseBalance) Total_Borrowed
FROM	Master.dbo.Account A
		INNER JOIN Master.dbo.AccountCustomer AC on A.AccountId = AC.AccountId
		INNER JOIN Master.dbo.Customer C on AC.CustomerId = C.CustomerId
GROUP BY C.CustomerId,
		C.FirstName,
		C.LastName

		
-- Get portfolio composition by Product type.
SELECT	P.PortfolioName,
		zP.ProductName,
		COUNT(*)
FROM	Master.dbo.Account A
		INNER JOIN Master.dbo.Portfolio P on A.PortfolioId = P.PortfolioId
		INNER JOIN Master.dbo.zProductType zP on A.ProductType = zP.ProductType
GROUP BY P.PortfolioName,
		zP.ProductName
ORDER BY 1,
		2

		
-- Get Customer's collections.
SELECT	C.FirstName,
		C.LastName,
		A.AccountId,
		A.PurchaseBalance,
		sum(COL.TransactionAmount) Collections
FROM	Master.dbo.Account A
		INNER JOIN Master.dbo.AccountCustomer AC on A.AccountId = AC.AccountId
		INNER JOIN Master.dbo.Customer C on AC.CustomerId = C.CustomerId
		INNER JOIN Master.dbo.Collections COL on A.AccountId = COL.AccountId
GROUP BY C.FirstName,
		C.LastName,
		A.AccountId,
		A.PurchaseBalance

		
-- How Many open accounts does each customer have.
SELECT	C.FirstName,
		C.LastName,
		SUM(CASE WHEN t.Status = 1 then 1 else 0 end) N_Closed,
		SUM(CASE WHEN t.Status > 0 and t.Status < 1 then 1 else 0 end) N_Partial,
		COUNT(*) N_Total
FROM	(
			SELECT	C.CustomerId,
					A.AccountId,
					sum(COL.TransactionAmount) / A.PurchaseBalance Status
			FROM	Master.dbo.Account A
					INNER JOIN Master.dbo.AccountCustomer AC on A.AccountId = AC.AccountId
					INNER JOIN Master.dbo.Customer C on AC.CustomerId = C.CustomerId
					INNER JOIN Master.dbo.Collections COL on A.AccountId = COL.AccountId
			GROUP BY C.CustomerId,
					A.AccountId,
					A.PurchaseBalance
		) t
		INNER JOIN Master.dbo.Customer C on t.CustomerId = C.CustomerId
GROUP BY C.FirstName,
		C.LastName

		
-- Have any Customers settled all accounts?
SELECT	C.FirstName,
		C.LastName,
		SUM(t.Closed) N_Closed,
		COUNT(*) N_Total
FROM	(
			SELECT	C.CustomerId,
					A.AccountId,
					CASE WHEN sum(COL.TransactionAmount) - A.PurchaseBalance >= 0 THEN 1 ELSE 0 END Closed
			FROM	Master.dbo.Account A
					INNER JOIN Master.dbo.AccountCustomer AC on A.AccountId = AC.AccountId
					INNER JOIN Master.dbo.Customer C on AC.CustomerId = C.CustomerId
					INNER JOIN Master.dbo.Collections COL on A.AccountId = COL.AccountId
			GROUP BY C.CustomerId,
					A.AccountId,
					A.PurchaseBalance
		) t
		INNER JOIN Master.dbo.Customer C on t.CustomerId = C.CustomerId
GROUP BY C.FirstName,
		C.LastName
HAVING	SUM(t.Closed) = COUNT(*)