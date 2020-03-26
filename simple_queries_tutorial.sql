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

select * from #numbers

select 	*,number + 1, 'hi', number, power(number,2)
from 	#numbers
where	number >= 5



select 	sum(power(number,2))
from 	#numbers AS N
where	number >= 5


select	*
from #numbers AS N
		inner join #numbers AS M ON M.number >= N.number
order by N.number, M.number



































--sum of cubes for n between 3 and 6 inc.
SELECT sum(power(number,3)), number%2
FROM #Numbers as N
WHERE 3<=number AND number<=6
GROUP BY number%2
