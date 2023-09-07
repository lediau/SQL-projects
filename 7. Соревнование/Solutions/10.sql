drop table if exists inv, metrics;

create temp table inv as( 
select investors.id as iid, received, investor_name
from transactions, investors
where transactions.investor_id = investors.id
   and type_of_invest = 'Invest'
order by investors.id
);

create temp table metrics as (
select iid, MAX(received) as ma, MIN(received) as mi, AVG(received) as av
from inv
group by iid, investor_name
);

ALTER TABLE inv 
ADD maximum float,
ADD minimum float,
ADD average float,
ADD metric float;

update inv
set maximum = metrics.ma from metrics
where inv.iid = metrics.iid;

update inv
set minimum = metrics.mi from metrics
where inv.iid = metrics.iid;

update inv
set average = metrics.av from metrics
where inv.iid = metrics.iid;

update inv
set metric = (maximum - received - minimum) / average;

select count(distinct iid) as low_metric_investors
from inv
where metric < -0.02;
