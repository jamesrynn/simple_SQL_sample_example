/*
Solutions to Part 2 of the Query Tasks.
*/


-- Q5: Which portfolio are people most likely to pay into?




-- Q6: Which product type are people most likely to pay into?



/*
Q7: What is the pay rate over the last 12 months? That is the number of customers who have paid in the last 12 months divided by the number of customers who 
had not cleared their balance in the last 12 months.
*/


-- Q4: Which customer has the highest number of accounts?
-- Solution 1: Count the number of accounts each customer has and list them in decreasing order. Read the answer from the top of the table that is returned.
SELECT 		TOP 5 C.FirstName, C.LastName, AC.CustomerId, COUNT(AC.AccountId) AS NumAcc
FROM 		AccountCustomer AS AC
			INNER JOIN Customer AS C ON AC.CustomerId = C.CustomerId 
GROUP BY 	C.FirstName, C.LastName, AC.CustomerId
ORDER BY 	COUNT(AC.AccountId) DESC

	
-- Solution 2: Count the number of accounts each customer has using a subquery and then retrievefrom that the maximum value of the results returned.
-- Note that here we do not return the details of the customer/customers who has/have this number of accounts.
SELECT 	MAX(S.NumAcc) AS MaxNAccounts
FROM 	(
		SELECT 		C.FirstName, C.LastName, AC.CustomerId, COUNT(AC.AccountId) AS NumAcc
		FROM 		AccountCustomer AS AC
					INNER JOIN Customer AS C ON AC.CustomerId = C.CustomerId 
		GROUP BY 	C.FirstName, C.LastName, AC.CustomerId) AS S

	

				

