/*
Solutions to Part 2 of the Query Tasks.
*/


-- Q5: Which portfolio are people most likely to pay into?
-- i.e., Number of people who have ever paid / number of people in portfolio.
---------------------------------------------------------------------------------------
SELECT 		A.PortfolioId,
			COUNT(A.AccountId) AS NumAccounts,
			AVG(
				CASE WHEN S.AccountId IS NOT NULL 
       			THEN 1.0
       			ELSE 0.0
				END
				) AS PayRate
				
FROM 		Account AS A
			-- Accounts where payments have been made.
			LEFT JOIN	(
						SELECT 		A.AccountId,
									A.PortfolioId
									
						FROM 		Account AS A
									INNER JOIN Collections AS C ON A.AccountId = C.AccountId
									
						GROUP BY	A.AccountId,
									A.PortfolioId 
									
						HAVING		SUM(C.TransactionAmount)>0
	 					) AS S ON A.AccountId = S.AccountId
	 					
GROUP BY    A.PortfolioId

ORDER BY	A.PortfolioId
---------------------------------------------------------------------------------------




-- Q6: Which product type are people most likely to pay into?
---------------------------------------------------------------------------------------
SELECT 		A.ProductType,
			COUNT(A.AccountId) AS NumAccounts,
			AVG(
				CASE WHEN S.AccountId IS NOT NULL 
       			THEN 1.0
       			ELSE 0.0
				END
				) AS PayRate
				
FROM 		Account AS A
			-- Accounts where payments have been made.
			LEFT JOIN	(
						SELECT 		A.AccountId,
									A.ProductType
									
						FROM 		Account AS A
									INNER JOIN Collections AS C ON A.AccountId = C.AccountId
									
						GROUP BY	A.AccountId,
									A.ProductType 
									
						HAVING		SUM(C.TransactionAmount)>0
	 					) AS S ON A.AccountId = S.AccountId
	 					
GROUP BY    A.ProductType

ORDER BY	A.ProductType
---------------------------------------------------------------------------------------




---------------------------------------------------------------------------------------
-- Q7: What is the pay rate over the last 12 months?
-- That is, the number of customers who have paid in the last 12 months divided by the number of customers who 
-- had not cleared their balance in the last 12 months.
---------------------------------------------------------------------------------------
SELECT 		* --SUM(
				--CASE WHEN S.SumPaid12Months IS NOT NULL
				--THEN 1.0
				--ELSE 0.0
				--END)  -- AS NumPayed

FROM 		Account AS A
			-- Accounts with payments in the last 12 months.
			LEFT JOIN	(
						SELECT		A.AccountId,
									SUM(C.TransactionAmount) AS SumPaid12Months
						
						FROM		Account AS A
									INNER JOIN Collections AS C ON A.AccountId = C.AccountId
						
						WHERE 		C.TransactionDate > DATEADD(year,-1,GETDATE())
						
						GROUP BY	A.AccountId
						
						HAVING 		SUM(C.TransactionAmount)>0
						)
						AS S ON A.AccountId = S.AccountId
						
			-- Accounts of customers who had not cleared their balances in last 12 months.
			LEFT JOIN	(
						SELECT 		A.AccountId
						
						FROM		Account AS A
									INNER JOIN Collections AS C ON A.AccountId = C.AccountId
									
						GROUP BY A.AccountId, A.PurchaseBalance
						
						HAVING		SUM(C.TransactionAmount) < A.PurchaseBalance
						) AS T ON A.AccountId = T.AccountId
					
--ORDER BY	A.AccountId
		




				

