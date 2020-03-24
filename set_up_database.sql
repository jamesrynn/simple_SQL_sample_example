/*
 * Begin ListOfNumbers creation
 */
IF OBJECT_ID('tempdb.dbo.#numbers', 'U') IS NOT NULL
begin
	print('Dropping table #Numbers')
	DROP TABLE #numbers
end
	
create	table #numbers
		(number INT)
insert	into #numbers
values	(1),(2),(3),(4),(5),(6),(7),(8),(9),(10)

IF OBJECT_ID('Master.dbo.ListOfNumbers', 'U') IS NOT NULL
	DROP TABLE Master.dbo.ListOfNumbers
SELECT	((n1.number -1) *10 + (n2.number-1))*10 + n3.number number
INTO	Master.dbo.ListOfNumbers
FROM	#numbers n1
		cross join #numbers n2
		cross join #numbers n3
order by 1

create clustered index clix on Master.dbo.ListOfNumbers (number)

SELECT	*
FROM	master.dbo.ListOfNumbers

/*
 * Begin Master.dbo.Portfolio creation
 */
if object_id('Master.dbo.Portfolio', 'U') is not NULL
begin
	if (select count(*) from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = 'FK_Account_PortfolioId') = 1
	begin
		print('dropping constraint FK_Account_PortfolioId')
		ALTER TABLE Master.dbo.Account 
		DROP CONSTRAINT FK_Account_PortfolioId
	end
	drop table Master.dbo.Portfolio
end

create	table Master.dbo.Portfolio
		(PortfolioId int primary key,
		 PortfolioName varchar(max),
		 DateAcquired DATE,
		 FaceValue MONEY)

INSERT	INTO Master.dbo.Portfolio
		(PortfolioId, PortfolioName, DateAcquired)
VALUES
		(1, 'HSBC', '2010-04-15'),
		(2, 'Lloyds', '2003-11-04'),
		(3, 'MBNA', '2016-04-13'),
		(4, 'Virgin', '2013-07-22')
		
/*
 * Begin Master.dbo.Account creation
 */
if object_id('Master.dbo.Account', 'U') is not NULL
begin
	if (select count(*) from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = 'FK_Collections_AccountId') = 1
		alter table Master.dbo.Collections
		drop constraint FK_Collections_AccountId
	if (select count(*) from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = 'FK_AccountCustomer_AccountId') = 1
		alter table Master.dbo.AccountCustomer
		drop constraint FK_AccountCustomer_AccountId
	drop table Master.dbo.Account
end
	
create	table Master.dbo.Account
		(AccountId int primary key,
		 PortfolioId int constraint FK_Account_PortfolioId foreign key references Master.dbo.Portfolio(PortfolioId),
		 ProductType int,
		 PurchaseBalance MONEY)
			
INSERT	INTO Master.dbo.Account
		(AccountId, PortfolioId, ProductType)
SELECT	number,
		case when ca.urn < 0.1 then 1
			 when ca.urn < 0.3 then 2
			 when ca.urn < 0.8 then 3
			 else 4
		end,
		case when ca2.urn < 0.1 then 1
			 when ca2.urn < 0.25 then 2
			 when ca2.urn < 0.7 then 3
			 when ca2.urn < 0.85 then 4
			 else 5
		end
FROM	Master.dbo.ListOfNumbers lon
		cross apply (select rand(checksum(newid())) urn) ca
		cross apply (select rand(checksum(newid())) urn) ca2
WHERE	number between 1 and 1000

UPDATE	Master.dbo.Account
SET		PurchaseBalance = 50+exp(10*rand(checksum(newid())))

SELECT	*
FROM	Master.dbo.Account

/*
 * Product type lookup
 */

IF OBJECT_ID('Master.dbo.zProductType', 'U') IS NOT NULL
	DROP TABLE Master.dbo.zProductType

CREATE TABLE Master.dbo.zProductType
	(ProductType INT PRIMARY KEY, ProductName VARCHAR(15))
INSERT INTO Master.dbo.zProductType
VALUES
	(1,'Credit Card'),
	(2, 'Loan'),
	(3, 'Store Card'),
	(4, 'Mortgage'),
	(5, 'Telecom')
	
/*
 * Begin Master.dbo.Customer creation
 */

if object_id('Master.dbo.Customer', 'U') is not NULL
begin
	if (select count(*) from INFORMATION_SCHEMA.REFERENTIAL_CONSTRAINTS where CONSTRAINT_NAME = 'FK_AccountCustomer_CustomerId') = 1
		alter table Master.dbo.AccountCustomer
		drop constraint FK_AccountCustomer_CustomerId
	drop table Master.dbo.Customer
END
	
create	table Master.dbo.Customer
		(CustomerId int primary key,
		 FirstName varchar(max),
		 LastName varchar(max),
		 DateOfBirth Date)

INSERT	INTO master.dbo.Customer (CustomerId,FirstName,LastName,DateOfBirth) VALUES 
		(1,'Luís','Gonçalves','1991-04-12')
		,(2,'Leonie','Köhler','1980-02-10')
		,(3,'François','Tremblay','1963-02-27')
		,(4,'Bjørn','Hansen','1953-09-12')
		,(5,'František','Wichterlová','1993-04-03')
		,(6,'Helena','Holý','1992-07-17')
		,(7,'Astrid','Gruber','1966-08-31')
		,(8,'Daan','Peeters','1983-05-21')
		,(9,'Kara','Nielsen','1987-04-14')
		,(10,'Eduardo','Martins','1978-07-13')
		,(11,'Alexandre','Rocha','1991-06-24')
		,(12,'Roberto','Almeida','1956-01-17')
		,(13,'Fernanda','Ramos','1994-07-03')
		,(14,'Mark','Philips','1956-01-21')
		,(15,'Jennifer','Peterson','1967-01-16')
		,(16,'Frank','Harris','1973-03-05')
		,(17,'Jack','Smith','1983-05-11')
		,(18,'Michelle','Brooks','1963-11-24')
		,(19,'Tim','Goyer','1951-03-07')
		,(20,'Dan','Miller','1998-12-23')
		,(21,'Kathy','Chase','1969-07-29')
		,(22,'Heather','Leacock','1952-05-26')
		,(23,'John','Gordon','1973-05-02')
		,(24,'Frank','Ralston','1989-04-14')
		,(25,'Victor','Stevens','1982-01-31')
		,(26,'Richard','Cunningham','1996-12-25')
		,(27,'Patrick','Gray','1956-02-29')
		,(28,'Julia','Barnett','1997-01-24')
		,(29,'Robert','Brown','1996-06-23')
		,(30,'Edward','Francis','1976-08-15')
		,(31,'Martha','Silk','1990-10-24')
		,(32,'Aaron','Mitchell','1998-12-12')
		,(33,'Ellie','Sullivan','1988-07-13')
		,(34,'João','Fernandes','1953-01-10')
		,(35,'Madalena','Sampaio','1980-11-11')
		,(36,'Hannah','Schneider','1977-09-15')
		,(37,'Fynn','Zimmermann','1955-03-02')
		,(38,'Niklas','Schröder','1975-09-18')
		,(39,'Camille','Bernard','1989-04-13')
		,(40,'Dominique','Lefebvre','1994-07-12')
		,(41,'Marc','Dubois','1987-12-08')
		,(42,'Wyatt','Girard','1958-11-20')
		,(43,'Isabelle','Mercier','1967-03-12')
		,(44,'Terhi','Hämäläinen','1990-04-26')
		,(45,'Ladislav','Kovács','1989-02-12')
		,(46,'Hugh','O''Reilly','1974-02-05')
		,(47,'Lucas','Mancini','1968-07-21')
		,(48,'Johannes','Van der Berg','1971-08-04')
		,(49,'Stanislaw','Wójcik','1956-02-06')
		,(50,'Enrique','Muñoz','1996-07-13')
		,(51,'Joakim','Johansson','1962-12-04')
		,(52,'Emma','Jones','1963-06-09')
		,(53,'Phil','Hughes','1970-05-03')
		,(54,'Steve','Murray','1962-03-14')
		,(55,'Mark','Taylor','1956-09-08')
		,(56,'Diego','Gutiérrez','1987-02-17')
		,(57,'Luis','Rojas','1986-03-14')
		,(58,'Manoj','Pareek','1985-02-17')
		,(59,'Puja','Srivastava','1987-02-25')


SELECT	*
FROM	Master.dbo.Customer

-- Link Account to Customer

IF OBJECT_ID('Master.dbo.AccountCustomer', 'U') IS NOT NULL
	DROP TABLE Master.dbo.AccountCustomer


create table Master.dbo.AccountCustomer
	(AccountId int unique constraint FK_AccountCustomer_AccountId foreign key references Master.dbo.Account(AccountId),
	 CustomerId int constraint FK_AccountCustomer_CustomerId foreign key references Master.dbo.Customer(CustomerId))


insert into Master.dbo.AccountCustomer (AccountId, CustomerId)
select	lon.number,
		floor(59*rand(checksum(newid())))+1
from	Master.dbo.ListOfNumbers lon
where	lon.number between 1 and 1000
order by lon.number


create clustered index clix on Master.dbo.AccountCustomer (AccountId)

SELECT	*
FROM	master.dbo.AccountCustomer

/*
 *  Generate Master.dbo.Collections
 */

-- make list of payers
IF OBJECT_ID('tempdb.dbo.#Payers', 'U') IS NOT NULL
	DROP TABLE #Payers
SELECT	AccountId,
		PortfolioId,
		case when PortfolioId = 1 then case when rand(checksum(newid())) < 0.1 then 1 else 0 end
			 when PortfolioId = 2 then case when rand(checksum(newid())) < 0.15 then 1 else 0 end
			 when PortfolioId = 3 then case when rand(checksum(newid())) < 0.3 then 1 else 0 end
			 else case when rand(checksum(newid())) < 0.05 then 1 else 0 end
		end |
		case when ProductType = 1 then case when rand(checksum(newid())) < 0.05 then 1 else 0 end
			 when ProductType = 2 then case when rand(checksum(newid())) < 0.1 then 1 else 0 end
			 when ProductType = 3 then case when rand(checksum(newid())) < 0.3 then 1 else 0 end
			 when ProductType = 4 then case when rand(checksum(newid())) < 0.08 then 1 else 0 end
			 else case when rand(checksum(newid())) < 0.05 then 1 else 0 end
		end
		Payers
INTO	#Payers
FROM	Master.dbo.Account

if object_id('Master.dbo.Collections', 'U') is not NULL
	drop table Master.dbo.Collections


create	table Master.dbo.Collections
		(AccountId int constraint FK_Collections_AccountId foreign key references Master.dbo.Account(AccountId),
		 TransactionDate DATE,
		 TransactionAmount MONEY)

INSERT	INTO Master.dbo.Collections
SELECT	A.AccountId,
		c.TransactionDate,
		case when pay.Payers = 1
			 then (10.0*case when A.ProductType = 1 then 1
			 				 when A.ProductType = 2 then 1.1
			 				 when A.ProductType = 3 then 0.7
			 				 when A.ProductType = 4 then 1
			 				 else 2
			 			end
			 		  *case when P.PortfolioId = 1 then 1.2
			 		  		when P.PortfolioId = 2 then 1.0
			 		  		when P.PortfolioId = 3 then 2.0
			 		  		else 0.7
			 		   end
			 		   + case when LEN(CU.LastName) < 5 then 5.0 else 0.0 end
			 		   + floor(rand(checksum(CU.FirstName))*100.0)/10.0)
			 		   *case when datediff(year, CU.dateofbirth, c.TransactionDate) between 18 and 65 
			 		  		then 1.0
			 		  		else 0.0
			 		   end
			 else 0.0
		end TransactionAmount
FROM	Master.dbo.Account A
		inner join #Payers pay on A.AccountId = pay.accountId
		inner join Master.dbo.AccountCustomer AC on A.AccountId = AC.AccountId
		inner join Master.dbo.Customer CU on AC.CustomerId = CU.CustomerId
		inner join Master.dbo.Portfolio P on A.PortfolioId = P.PortfolioId
		inner join Master.dbo.ListOfNumbers lon on number between 1 and datediff(MONTH, DateAcquired, getdate())
		cross apply (select dateadd(month, number, dateadd(day, 1-day(dateacquired), dateacquired)) TransactionDate) c
WHERE	number between floor(20*rand(checksum(newid())))
				and floor(datediff(MONTH, DateAcquired, getdate())*rand(checksum(newid())))
		
UPDATE	Master.dbo.Collections
SET		TransactionAmount = 0
FROM	Master.dbo.Collections C
		inner join (select	top 30 percent *
					FROM	Master.dbo.Collections
					Order by newid()) C2 on C.AccountId = C2.accountid and C.TransactionDate = C2.transactionDate

UPDATE	Master.dbo.Collections
SET		TransactionAmount = A.PurchaseBalance
FROM	Master.dbo.Collections C
		inner join Master.dbo.Account A on C.AccountId = A.AccountId
		inner join (select	C.*,
							row_number() over (partition by C.AccountId order by newid()) rn
					FROM	Master.dbo.Collections C
							inner join #Payers p on C.AccountId = p.accountId
							inner join Master.dbo.Account A on C.AccountId = A.AccountId
					WHERE	p.Payers = 0
							and rand(checksum(newid())) < case when A.PurchaseBalance < 300 then 0.2 else 0.1 end
					) C2 on C.AccountId = C2.accountid and C.TransactionDate = C2.transactionDate
WHERE	rn = 1

SELECT	*
FROM	Master.dbo.Collections




-- Calc Arrangement Value
IF OBJECT_ID('tempdb.dbo.#OverPayingAccounts', 'U') IS NOT NULL
	DROP TABLE #OverPayingAccounts

SELECT	A.AccountId,
		sum(C.TransactionAmount) Collections,
		A.PurchaseBalance
INTO	#OverPayingAccounts
FROM	Master.dbo.Account A
		inner join Master.dbo.Collections C on A.AccountId = C.AccountId
GROUP BY A.AccountId,
		A.PurchaseBalance
HAVING	SUM(C.TransactionAmount) > A.PurchaseBalance

--------------- CBA to cap payments so just adjust.

UPDATE	A
SET		PurchaseBalance = O.Collections
FROM	Master.dbo.Account A
		INNER JOIN #OverPayingAccounts O on A.AccountId = O.AccountId

UPDATE	P
SET		FaceValue = A.PurchaseBalance
FROM	Master.dbo.Portfolio P
		inner join (SELECT	PortfolioId, sum(PurchaseBalance) PurchaseBalance
              		FROM	Master.dbo.Account
              		GROUP BY PortfolioId) A on P.PortfolioId = A.PortfolioId

SELECT	*
FROM	Master.dbo.Portfolio