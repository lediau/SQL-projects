with ad as (
 select distinct company_id, 1, 1, 'Credit', CAST('2006-01-01' as timestamp) as dt
 from transactions
)
insert into transactions
select 100000 + company_id, * from ad;

with ad as (
 select distinct company_id, 1, 1, 'Credit', CAST('2006-01-01' as timestamp) as dt
 from transactions
)
insert into transaction_outcomes
select 0, 100000 + company_id, 1, dt from ad;

with ade as (
 select distinct company_id, 1, 1, 'Credit', CAST('2020-02-03' as timestamp) as dt
 from transactions
 where transactions.id != 8333 and transactions.id != 9790 and transactions.id != 19082 and
      transactions.id != 23648 and transactions.id != 25419 and transactions.id != 25465 and
   transactions.id != 36985 and transactions.id != 51402 and transactions.id != 52705 and
   transactions.id != 56281 and transactions.id != 61302 and transactions.id != 62590 and
   transactions.id != 67932 and transactions.id != 67996 and transactions.id != 69235
)

insert into transactions
select 200000 + company_id, * from ade;

with ade as (
 select distinct company_id, 1, 1, 'Credit', CAST('2020-02-03' as timestamp) as dt
 from transactions
 where transactions.id != 8333 and transactions.id != 9790 and transactions.id != 19082 and
      transactions.id != 23648 and transactions.id != 25419 and transactions.id != 25465 and
   transactions.id != 36985 and transactions.id != 51402 and transactions.id != 52705 and
   transactions.id != 56281 and transactions.id != 61302 and transactions.id != 62590 and
   transactions.id != 67932 and transactions.id != 67996 and transactions.id != 69235

)
insert into transaction_outcomes
select 0, 200000 + company_id, 1, dt from ade;

----------------------------------------------------------------------------
-- Теперь главная часть:

with credits as (
select t.id, t.company_id, t.received, tro.returned, 
 FLOOR(extract(epoch from t.dt - '2006-01-01')/3600/24) as x,
 CAST(tro.returned as float)/CAST(t.received as float) as y
from transactions as t
right join transaction_outcomes as tro
on t.id = tro.transaction_id
where type_of_invest = 'Credit' and tro.dt <= '2020-02-03'
order by company_id, x
),
shifts as (
select id, company_id, x, lag(x, 1, 0) over (order by company_id, x) as x_shifted,
    y, lag(y, 1, 0) over (order by company_id, x) as y_shifted
from credits
),
formulas as (
select id, company_id, x, x_shifted, y, y_shifted, 
    (y + y_shifted) * (x - x_shifted) / 2 as area
from shifts
),
sums as (
 select company_id, SUM(area) as ar
 from formulas
 group by company_id
)

select c.company_name, s.ar from sums as s join companies as c on s.company_id = c.id
order by -ar
limit 3;
