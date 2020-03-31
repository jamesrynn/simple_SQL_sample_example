/*
 * In this script we provide some basic queries as example.
 * Note that blocks of comment may be entered using the characters / and * as used here.
 */


-- First we create a temporary table numbers (referenced by #numbers) containing a single column 'number' which lists the integers 1,2,...,10.
IF OBJECT_ID('tempdb.dbo.#numbers', 'U') IS NOT NULL
BEGIN
	PRINT('Dropping table #Numbers')
	DROP TABLE #numbers
END

CREATE	TABLE #numbers
		(number INT)
INSERT	INTO #numbers
VALUES	(1),(2),(3),(4),(5),(6),(7),(8),(9),(10)



-- Select all entries from the temporary table, #numbers.
SELECT * FROM #numbers


-- Perform simple operations on the entries of #numbers.
SELECT 	*,number + 1, 'hi', number, power(number,2)
from 	#numbers
where	number >= 5


-- Sum the squares of the elememts of number.
select 	sum(power(number,2))
from 	#numbers AS N
where	N.number >= 5


-- Join to each entry in numbers a list of entries in numbers larger than the given entry.
-- Note, where there are multiple tables involved, we must specify the table the column we are referencing comes from.
select	*
from #numbers AS N
		inner join #numbers AS M ON M.number >= N.number
order by N.number, M.number


-- Sum the cubes of the numbers between 3 and 6 (inclusive).
SELECT sum(power(number,3))
FROM #Numbers as N
WHERE 3<=number AND number<=6


-- Sum separately the cubes of the odd and even numbers between 3 and 6 (inclusive).
SELECT sum(power(number,3)), number%2
FROM #Numbers as N
WHERE 3<=number AND number<=6
GROUP BY number%2 -- distinguish odd/even
