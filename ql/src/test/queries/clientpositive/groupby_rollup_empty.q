set hive.vectorized.execution.enabled=false;

drop table if exists tx1_n2;
drop table if exists tx2_n1;
create table tx1_n2 (a integer,b integer,c integer);

select sum(c)
from tx1_n2
;

select  sum(c),
        grouping(b),
	'NULL,1' as expected
from    tx1_n2
where	a<0
group by a,b grouping sets ((), b, a);

select  sum(c),
        grouping(b),
	'NULL,1' as expected
from    tx1_n2
where	a<0
group by rollup (b);

select '2 rows expected',sum(c) from tx1_n2 group by rollup (a)
union all
select '2 rows expected',sum(c) from tx1_n2 group by rollup (a);

-- non-empty table

insert into tx1_n2 values (1,1,1);

select  sum(c),
        grouping(b),
	'NULL,1' as expected
from    tx1_n2
where	a<0
group by rollup (b);

select  sum(c),
        grouping(b),
	'1,1 and 1,0' as expected
from    tx1_n2
group by rollup (b);


set hive.vectorized.execution.enabled=true;
create table tx2_n1 (a integer,b integer,c integer,d double,u string,bi binary) stored as orc;

explain
select  sum(c),
        grouping(b),
	'NULL,1' as expected
from    tx2_n1
where	a<0
group by a,b grouping sets ((), b, a);


select sum(c),'NULL' as expected
from tx2_n1;

select  sum(c),
	max(u),
	'asd',
        grouping(b),
	'NULL,1' as expected
from    tx2_n1
where	a<0
group by a,b,d grouping sets ((), b, a, d);

select '2 rows expected',sum(c) from tx2_n1 group by rollup (a)
union all
select '2 rows expected',sum(c) from tx2_n1 group by rollup (a);

insert into tx2_n1 values
(1,2,3,1.1,'x','b'),
(3,2,3,1.1,'y','b');

select  sum(a),
	u,
	bi,
	'asd',
        grouping(bi),
	'NULL,1' as expected
from    tx2_n1
where	a=2
group by a,u,bi grouping sets ( u, (), bi);
