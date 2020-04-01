/*
Solutions to Part 2 of the Query Tasks.
*/


-- Q5: Which portfolio are people most likely to pay into?
SELECT		A.PortfolioId, COUNT(C.TransactionAmount) AS NumPayments
FROM 		Account AS A
			INNER JOIN Collections AS C ON A.AccountId = C.AccountId 
WHERE 		C.TransactionAmount>0
GROUP BY 	A.PortfolioID
ORDER BY	NumPayments DESC

SELECT PortfolioID 


-- Get Account Ids with Positive transaction amounts
(
SELECT 		A.AccountId, A.PortfolioId, SUM(C.TransactionAmount) AS TotalPayed
FROM 		Account AS A
			INNER JOIN Collections 	AS C ON A.AccountId = C.AccountId
GROUP BY	A.AccountId, A.PortfolioId 
HAVING		SUM(C.TransactionAmount)>0
ORDER BY 	A.AccountId
) AS M 


-- Get Account Ids with 0 total transaction amounts
(
SELECT		A.AccountId, SUM(C.TransactionAmount) AS TotalPayed
FROM 		Account AS A
			INNER JOIN Collections AS C ON A.AccountId = C.AccountId
GROUP BY 	A.AccountId
HAVING		SUM(C.TransactionAmount)=0
			OR
			ISNULL(1,C.TransactionAmount)=1
ORDER BY 	A.AccountId
) AS N



INNER JOIN Portfolio 	AS P ON A.PortfolioId = P.PortfolioId
-- Q6: Which product type are people most likely to pay into?



-- Q7: What is the pay rate over the last 12 months? That is the number of customers who have paid in the last 12 months divided by the number of customers who 
--had not cleared their balance in the last 12 months.





				

