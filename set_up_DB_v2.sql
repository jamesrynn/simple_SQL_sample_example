/*
View metadata
=============
List all user-defined base tables and views.
	SELECT name FROM SYSOBJECTS WHERE xtype = 'U' ORDER BY name;

List all base tables in <database_name>.
	SELECT table_name, table_schema FROM tempdb.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY table_name;
	SELECT table_name, table_schema FROM master.INFORMATION_SCHEMA.TABLES WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY table_name;
*/
---------------------------------------------------------------------------------------




-- Create temporary table #Numbers.
-- (dbo.#Numbers is stored in tempdb and exists until the current connection is closed)
DROP TABLE IF EXISTS #Numbers;   -- if temporary table #Numbers exists, remove it

/*
-- Alternatively, remove any user defined temporary table called #Numbers.
-- Note: May not work if database connection has not been renewed since last use.

IF OBJECT_ID('tempdb.dbo.#numbers', 'U') IS NOT NULL
BEGIN
	PRINT('Dropping table #Numbers')
	DROP TABLE #Numbers
END
*/
---------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------
-- Create new temporary table called #Numbers and fill the first column (Number) with integers 1,2,...,10.
CREATE TABLE #Numbers (Number INT)
INSERT INTO #Numbers VALUES (1),(2),(3),(4),(5),(6),(7),(8),(9),(10); -- brackets indicate entries in different rows

-- Display the table created.
SELECT 	* 
FROM 	#Numbers;
---------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------
-- Remove any user defined base table (i.e., not a view) called ListOfNumbers.
IF OBJECT_ID('master.dbo.ListOfNumbers','U') IS NOT NULL
	BEGIN
		DROP TABLE master.dbo.ListOfNumbers   -- using (BEGIN,END) pair allows multiple statements within if statement.
		PRINT('Deleted table ListOfNumbers.')
	END;
---------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------
-- Create (base) table ListOfNumbers, which is stored in master.
SELECT 		((n1.Number-1)*10 + (n2.Number-1))*10 + n3.Number AS Number  -- this construction is based on Horner's method (see https://en.wikipedia.org/wiki/Horner%27s_method).

INTO 		master.dbo.ListOfNumbers

FROM 		#Numbers AS n1
			CROSS JOIN #Numbers AS n2
			CROSS JOIN #Numbers AS n3

ORDER BY	1;


-- Create index for efficiency of searching/querying.
CREATE CLUSTERED INDEX clix ON master.dbo.ListOfNumbers(Number);


-- The result is a column Number of unique numeric values 1 to 1000.
SELECT 	* 
FROM 	master.dbo.ListOfNumbers;
---------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------
-- Create (base) table Portfolio.
IF OBJECT_ID('master.dbo.Portfolio', 'U') IS NOT NULL -- Begin by removing any old version.
	BEGIN
		-- Before removing, we must check for links to other tables.
		IF	(
			SELECT 	COUNT(*) 
			FROM 	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
			WHERE 	CONSTRAINT_NAME = 'FK_Account_PortfolioId' -- FK here stands for 'Foreign Key'
			) = 1		
			-- If a link is found (here we know/assume in advance there will be one), delete the link and then delete the table.
			BEGIN
				ALTER TABLE 	master.dbo.Account 
				DROP CONSTRAINT FK_Account_PortfolioId
				PRINT			('Deleted constraint FK_Account_PortfolioId.')
				DROP TABLE 		master.dbo.Portfolio
				PRINT			('Deleted table Portfolio.')
			END
	END;

	
-- Now create a new table.
CREATE TABLE master.dbo.Portfolio	(
									PortfolioId 	INT 			PRIMARY KEY, -- all tables should have a primary key
									PortfolioName 	VARCHAR(MAX),
									DateAcquired 	DATE,
									FaceValue 		MONEY
									);

								
-- Populate the table.						
INSERT INTO master.dbo.Portfolio (PortfolioId, PortfolioName, DateAcquired)
VALUES
	(1, 'HSBC',   '2010-04-15'),
	(2, 'Lloyds', '2003-11-04'),
	(3, 'MBNA',   '2016-04-13'),
	(4, 'Virgin', '2013-07-22');


-- View table for sanity check.
SELECT 	PortfolioId, PortfolioName, DateAcquired
FROM 	master.dbo.Portfolio;
---------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------
-- Create (base) table Account.
IF OBJECT_ID('master.dbo.Account', 'U') IS NOT NULL
	BEGIN
		IF	(
			SELECT 	COUNT(*) 
			FROM 	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
			WHERE 	CONSTRAINT_NAME = 'FK_Collections_AccountId'
			) = 1
			BEGIN
				ALTER TABLE 	master.dbo.Collections
				DROP CONSTRAINT FK_Collections_AccountId
				PRINT			('Deleted constraint FK_Collections_AccountId.')
			END
		IF 	(
			SELECT 	COUNT(*) 
			FROM 	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS 
			WHERE 	CONSTRAINT_NAME = 'FK_AccountCustomer_AccountId'
			) = 1
			BEGIN
				ALTER TABLE 	master.dbo.AccountCustomer
				DROP CONSTRAINT FK_AccountCustomer_AccountId
				PRINT			('Deleted constraint FK_AccountCustomer_AccountId.')
			END
	
		DROP TABLE	master.dbo.Account
		PRINT		('Deleted table Account.');
	
	END;


CREATE TABLE master.dbo.Account	(
								AccountId 		INT 	PRIMARY KEY,
								PortfolioId 	INT 	CONSTRAINT FK_Account_PortfolioId FOREIGN KEY REFERENCES master.dbo.Portfolio(PortfolioId),
								ProductType 	INT,
								PurchaseBalance MONEY
								);
			
							
INSERT INTO master.dbo.Account (AccountId, PortfolioId, ProductType)
	SELECT LON.Number,
		CASE
			WHEN CA1.URN < 0.1  THEN 1
			WHEN CA1.URN < 0.3  THEN 2	-- select PortfolioId using probability distribution
			WHEN CA1.URN < 0.8  THEN 3
			ELSE 4
		END,
		CASE
			WHEN CA2.URN < 0.1 	THEN 1
			WHEN CA2.URN < 0.25 THEN 2
			WHEN CA2.URN < 0.7 	THEN 3  -- select ProductType using probability distribution
			WHEN CA2.URN < 0.85 THEN 4
			ELSE 5
		END
	FROM master.dbo.ListOfNumbers AS LON
		CROSS APPLY (SELECT RAND(CHECKSUM(NEWID())) AS URN) AS CA1
		CROSS APPLY (SELECT RAND(CHECKSUM(NEWID())) AS URN) AS CA2;

		
UPDATE 	master.dbo.Account
SET 	PurchaseBalance = ROUND(50 + EXP(10 * RAND(CHECKSUM(NEWID()))), 2); -- PurchaseBalance values rounded to 2 decimal places


-- View table.
SELECT 	*
FROM 	master.dbo.Account;  
---------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------
-- Create lookup table zProductType.
IF OBJECT_ID('master.dbo.zProductType', 'U') IS NOT NULL
	BEGIN
		DROP TABLE	master.dbo.zProductType;
		PRINT		('Deleted table zProductType.');
	END

CREATE TABLE master.dbo.zProductType(
										ProductType INT 		PRIMARY KEY, 
										ProductName VARCHAR(15)
									);

INSERT INTO master.dbo.zProductType
VALUES
	(1, 'Credit Card'),
	(2, 'Loan'),
	(3, 'Store Card'),
	(4, 'Mortgage'),
	(5, 'Telecom');


SELECT 	*
FROM 	master.dbo.zProductType;
---------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------
-- Create base table Customer.
IF OBJECT_ID('master.dbo.Customer', 'U') IS NOT NULL
	BEGIN
		IF	(
			SELECT 	COUNT(*) 
			FROM 	INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS
			WHERE 	CONSTRAINT_NAME = 'FK_AccountCustomer_CustomerId'
			) = 1
		ALTER TABLE 	master.dbo.AccountCustomer
		DROP CONSTRAINT FK_AccountCustomer_CustomerId
	    PRINT			('Deleted constraint FK_AccountCustomer_CustomerId.')
		DROP TABLE 		master.dbo.Customer
	    PRINT			('Deleted table Customer.')
	END;


CREATE TABLE master.dbo.Customer(
								CustomerId 	INT 			PRIMARY KEY,
								FirstName 	VARCHAR(MAX),
								LastName 	VARCHAR(MAX),
								DateOfBirth DATE
								);

					
INSERT INTO master.dbo.Customer (CustomerId, FirstName, LastName, DateOfBirth)
VALUES 
	(1,'Luís','Gonçalves','1991-04-12'),
	(2,'Leonie','Köhler','1980-02-10'),
	(3,'François','Tremblay','1963-02-27'),
	(4,'Bjørn','Hansen','1953-09-12'),
	(5,'František','Wichterlová','1993-04-03'),
	(6,'Helena','Holý','1992-07-17'),
	(7,'Astrid','Gruber','1966-08-31'),
	(8,'Daan','Peeters','1983-05-21'),
	(9,'Kara','Nielsen','1987-04-14'),
	(10,'Eduardo','Martins','1978-07-13'),
	(11,'Alexandre','Rocha','1991-06-24'),
	(12,'Roberto','Almeida','1956-01-17'),
	(13,'Fernanda','Ramos','1994-07-03'),
	(14,'Mark','Philips','1956-01-21'),
	(15,'Jennifer','Peterson','1967-01-16'),
	(16,'Frank','Harris','1973-03-05'),
	(17,'Jack','Smith','1983-05-11'),
	(18,'Michelle','Brooks','1963-11-24'),
	(19,'Tim','Goyer','1951-03-07'),
	(20,'Dan','Miller','1998-12-23'),
	(21,'Kathy','Chase','1969-07-29'),
	(22,'Heather','Leacock','1952-05-26'),
	(23,'John','Gordon','1973-05-02'),
	(24,'Frank','Ralston','1989-04-14'),
	(25,'Victor','Stevens','1982-01-31'),
	(26,'Richard','Cunningham','1996-12-25'),
	(27,'Patrick','Gray','1956-02-29'),
	(28,'Julia','Barnett','1997-01-24'),
	(29,'Robert','Brown','1996-06-23'),
	(30,'Edward','Francis','1976-08-15'),
	(31,'Martha','Silk','1990-10-24'),
	(32,'Aaron','Mitchell','1998-12-12'),
	(33,'Ellie','Sullivan','1988-07-13'),
	(34,'João','Fernandes','1953-01-10'),
	(35,'Madalena','Sampaio','1980-11-11'),
	(36,'Hannah','Schneider','1977-09-15'),
	(37,'Fynn','Zimmermann','1955-03-02'),
	(38,'Niklas','Schröder','1975-09-18'),
	(39,'Camille','Bernard','1989-04-13'),
	(40,'Dominique','Lefebvre','1994-07-12'),
	(41,'Marc','Dubois','1987-12-08'),
	(42,'Wyatt','Girard','1958-11-20'),
	(43,'Isabelle','Mercier','1967-03-12'),
	(44,'Terhi','Hämäläinen','1990-04-26'),
	(45,'Ladislav','Kovács','1989-02-12'),
	(46,'Hugh','O''Reilly','1974-02-05'),
	(47,'Lucas','Mancini','1968-07-21'),
	(48,'Johannes','Van der Berg','1971-08-04'),
	(49,'Stanislaw','Wójcik','1956-02-06'),
	(50,'Enrique','Muñoz','1996-07-13'),
	(51,'Joakim','Johansson','1962-12-04'),
	(52,'Emma','Jones','1963-06-09'),
	(53,'Phil','Hughes','1970-05-03'),
	(54,'Steve','Murray','1962-03-14'),
	(55,'Mark','Taylor','1956-09-08'),
	(56,'Diego','Gutiérrez','1987-02-17'),
	(57,'Luis','Rojas','1986-03-14'),
	(58,'Manoj','Pareek','1985-02-17'),
	(59,'Puja','Srivastava','1987-02-25');

SELECT	* 
FROM 	master.dbo.Customer;
---------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------
-- Create link table AccountCustomer.
IF OBJECT_ID('master.dbo.AccountCustomer', 'U') IS NOT NULL
	DROP TABLE	master.dbo.AccountCustomer
	PRINT		('Deleted table AccountCustomer.');


CREATE TABLE master.dbo.AccountCustomer	(
										AccountId	INT UNIQUE CONSTRAINT 	FK_AccountCustomer_AccountId 	FOREIGN KEY REFERENCES Account(AccountId),
										CustomerId 	INT CONSTRAINT 			FK_AccountCustomer_CustomerId	FOREIGN KEY REFERENCES Customer(CustomerId)
										);

									
INSERT INTO master.dbo.AccountCustomer (AccountId, CustomerId)
	SELECT 		LON.Number,
				FLOOR(59 * RAND(CHECKSUM(NEWID()))) + 1
	FROM 		master.dbo.ListOfNumbers AS LON
	WHERE 		LON.Number BETWEEN 1 AND 1000
	ORDER BY 	LON.Number;


CREATE CLUSTERED INDEX clix ON master.dbo.AccountCustomer(AccountId);


SELECT 	*
FROM	master.dbo.AccountCustomer;
---------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------
-- Create temporary table #Payers
DROP TABLE IF EXISTS #Payers;

SELECT AccountId, PortfolioId,
	CASE 
		WHEN PortfolioId = 1 THEN
			CASE WHEN RAND(CHECKSUM(NEWID())) < 0.1 THEN 1 ELSE 0 END
		WHEN PortfolioId = 2 THEN
			CASE WHEN RAND(CHECKSUM(NEWID())) < 0.15 THEN 1 ELSE 0 END
		WHEN PortfolioId = 3 THEN
			CASE WHEN RAND(CHECKSUM(NEWID())) < 0.3 THEN 1 ELSE 0 END
		ELSE
			CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 1 ELSE 0 END
	END |
	CASE 
		WHEN ProductType = 1 THEN
			CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 1 ELSE 0 END
		WHEN ProductType = 2 THEN
			CASE WHEN RAND(CHECKSUM(NEWID())) < 0.1 THEN 1 ELSE 0 END
		WHEN ProductType = 3 THEN
			CASE WHEN RAND(CHECKSUM(NEWID())) < 0.3 THEN 1 ELSE 0 END
		WHEN ProductType = 4 THEN
			CASE WHEN RAND(CHECKSUM(NEWID())) < 0.08 THEN 1 ELSE 0 END
		ELSE
			CASE WHEN RAND(CHECKSUM(NEWID())) < 0.05 THEN 1 ELSE 0 END
	END AS Payers
INTO #Payers
FROM Account;

SELECT * FROM #Payers;
---------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------
-- Create base table Collections
IF OBJECT_ID('Collections', 'U') IS NOT NULL
	DROP TABLE Collections;
	PRINT('Deleted table Collections');
CREATE TABLE Collections
	(AccountId int CONSTRAINT FK_Collections_AccountId FOREIGN KEY REFERENCES Account(AccountId),
	TransactionDate date,
	TransactionAmount money);

INSERT INTO Collections
SELECT A.AccountId, c.TransactionDate,
	CASE
		WHEN pay.Payers = 1 THEN (10.0 * 
			CASE
				WHEN A.ProductType = 1 THEN 1
				WHEN A.ProductType = 2 THEN 1.1
				WHEN A.ProductType = 3 THEN 0.7
				WHEN A.ProductType = 4 THEN 1
				ELSE 2
			END *
			CASE
				WHEN P.PortfolioId = 1 THEN 1.2
				WHEN P.PortfolioId = 2 THEN 1.0
				WHEN P.PortfolioId = 3 THEN 2.0
				ELSE 0.7
			END +
			CASE
				WHEN LEN(CU.LastName) < 5 THEN 5.0
				ELSE 0.0
			END + FLOOR(RAND(CHECKSUM(CU.FirstName)) * 100.0) / 10.0) *
			CASE
				WHEN DATEDIFF(YEAR, CU.dateofbirth, c.TransactionDate) BETWEEN 18 AND 65 THEN 1.0
				ELSE 0.0
			END
		ELSE 0.0
	END AS TransactionAmount
FROM Account AS A
	INNER JOIN #Payers AS pay ON A.AccountId = pay.AccountId
	INNER JOIN AccountCustomer AS AC ON A.AccountId = AC.AccountId
	INNER JOIN Customer AS CU ON AC.CustomerId = CU.CustomerId
	INNER JOIN Portfolio AS P ON A.PortfolioId = P.PortfolioId
	INNER JOIN ListOfNumbers AS lon ON Number BETWEEN 1 AND DATEDIFF(MONTH, DateAcquired, GETDATE())
	CROSS APPLY (
		SELECT DATEADD(MONTH, Number, DATEADD(DAY, 1 - DAY(Dateacquired), Dateacquired)) TransactionDate) AS c
		WHERE Number BETWEEN FLOOR(20 * RAND(CHECKSUM(NEWID())))
		AND FLOOR(DATEDIFF(MONTH, DateAcquired, GETDATE()) * RAND(CHECKSUM(NEWID())));
		
UPDATE Collections
SET TransactionAmount = 0
FROM Collections AS C
	INNER JOIN (
		SELECT TOP 30 PERCENT *
		FROM Collections
		ORDER BY NEWID()) AS C2 ON C.AccountId = C2.Accountid AND C.TransactionDate = C2.TransactionDate

UPDATE Collections
SET TransactionAmount = A.PurchaseBalance
FROM Collections AS C
	INNER JOIN Account AS A ON C.AccountId = A.AccountId
	INNER JOIN (
		SELECT C.*, ROW_NUMBER() OVER (PARTITION BY C.AccountId ORDER BY NEWID()) AS rn
		FROM Collections C
			INNER JOIN #Payers AS p ON C.AccountId = p.AccountId
			INNER JOIN Account AS A ON C.AccountId = A.AccountId
		WHERE p.Payers = 0 AND RAND(CHECKSUM(NEWID())) < 
			CASE 
				WHEN A.PurchaseBalance < 300 THEN 0.2 
				ELSE 0.1
			END) AS C2 ON C.AccountId = C2.Accountid AND C.TransactionDate = C2.TransactionDate
WHERE rn = 1;

SELECT * FROM Collections;
---------------------------------------------------------------------------------------



---------------------------------------------------------------------------------------
-- Create temporary table #OverPayingAccounts
DROP TABLE IF EXISTS #OverPayingAccounts;

SELECT A.AccountId, SUM(C.TransactionAmount) AS Collections, A.PurchaseBalance
INTO #OverPayingAccounts
FROM Account AS A
	INNER JOIN Collections AS C ON A.AccountId = C.AccountId
GROUP BY A.AccountId, A.PurchaseBalance
HAVING SUM(C.TransactionAmount) > A.PurchaseBalance;

-- CBA to cap payments so adjust
UPDATE A
SET PurchaseBalance = O.Collections
FROM Account AS A
	INNER JOIN #OverPayingAccounts AS O ON A.AccountId = O.AccountId;

UPDATE P
SET FaceValue = A.PurchaseBalance
FROM Portfolio AS P
	INNER JOIN (
		SELECT PortfolioId, SUM(PurchaseBalance) AS PurchaseBalance
		FROM Account
		GROUP BY PortfolioId) AS A ON P.PortfolioId = A.PortfolioId;

SELECT PortfolioId, CONVERT(varchar(12),PortfolioName) AS PortfolioName, DateAcquired, FaceValue FROM  Portfolio;
---------------------------------------------------------------------------------------