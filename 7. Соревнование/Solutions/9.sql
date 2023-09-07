drop table if exists Filtered_transactions;

-- 13 Апреля 2008 года Николай Романов решил стать инвестором, 
-- и на последний деньги купил по 5 акций компаний 4 TanLab, Le Fe Waveenv и MayCev, 
-- и успешно забыл про них на несколько лет. Спустя несколько лет, 10 января 2017 года
create table Filtered_transactions as (
 select id, company_id, received::float, type_of_invest, dt
 from Transactions
 where (company_id = 1 or company_id = 307 or company_id = 1437) 
       and dt between '2008-04-13 00:00:00' and '2018-01-10 00:00:00'
);

-- Когда компании кто-то одобрял кредит, ее стоимость вырастала на половину от 
-- размера кредита, зато в день возвращения кредита, ее стоимость падала на удвоенное 
-- количество возвращенных денег.
INSERT INTO Filtered_transactions
SELECT ft.id, company_id, -tro.returned * 2 as received, 
    '-Credit' as type_of_invest, tro.dt as dt
FROM Filtered_transactions as ft
inner join Transaction_outcomes as tro
on ft.id = tro.transaction_id
WHERE type_of_invest = 'Credit';

Update Filtered_transactions 
Set received = received / 2 
where type_of_invest = 'Credit';

-- Когда компания получала пожертвование, ее (компании) стоимость увеличивалась на сумму 
-- пожертвования, но через 3 недели падала на половину от суммы пожертвования
INSERT INTO Filtered_transactions
SELECT id, company_id, -received / 2 as received, 
    '-Donation' as type_of_invest, dt + interval '3 weeks' as dt
FROM Filtered_transactions
WHERE type_of_invest = 'Donation';
with recursive u (i, dt, tl_cost, lfv_cost, mc_cost, roman_is_smart, type_of_invest) as (
 with ordered_ft as (
  select *, row_number() OVER () as r
  from (select * from Filtered_transactions order by dt) as o
 )
 select 
     1,
  ('2008-04-13 00:00:00'::timestamp),
  (select start_price from Companies where company_name = '4 TanLab')::float,
  (select start_price from Companies where company_name = 'Le Fe Waveenv')::float,
  (select start_price from Companies where company_name = 'MayCev')::float,
  0::float,
     ''
  
 union all
    
 select
     i + 1 as i,
     ordered_ft.dt as dt,
     -- 4 TanLab = 1, Le Fe Waveenv = 307, MayCev = 1437
  (case 
   when ordered_ft.company_id = 1
   then (case when u.tl_cost + ordered_ft.received < 0 then 0
          else u.tl_cost + ordered_ft.received end)
   else u.tl_cost 
  end) as tlp,
  (case
   when ordered_ft.company_id = 307
   then (case when u.lfv_cost + ordered_ft.received < 0 then 0
          else u.lfv_cost + ordered_ft.received end)
   else u.lfv_cost
  end) as lfwp,
  (case
   when ordered_ft.company_id = 1437
   then (case when u.mc_cost + ordered_ft.received < 0 then 0
          else u.mc_cost + ordered_ft.received end)
   else u.mc_cost
  end) as mcp,
     -- акции вырастали пропорционально (было 100 за акцию, инвестировали 2000000, акции стали 140)
  (case when ordered_ft.dt > '2017-01-10 00:00:00'
     then (case when ordered_ft.company_id = 1
        then (case when u.tl_cost + ordered_ft.received < 0 
             then u.roman_is_smart - u.tl_cost / 10000
          else u.roman_is_smart + ordered_ft.received / 10000 end)
        when ordered_ft.company_id = 307
        then (case when u.lfv_cost + ordered_ft.received < 0 
             then u.roman_is_smart - u.lfv_cost / 10000
         else u.roman_is_smart + ordered_ft.received / 10000 end)
        when ordered_ft.company_id = 1437
        then (case when u.mc_cost + ordered_ft.received < 0 
             then u.roman_is_smart - u.mc_cost / 10000
         else u.roman_is_smart + ordered_ft.received / 10000 end)
       else u.roman_is_smart
    end)
   else u.roman_is_smart
  end) as profit, ordered_ft.type_of_invest as type_of_invest
    
 from u
 join ordered_ft
 on u.i = ordered_ft.r
)

select FLOOR(roman_is_smart) from u
order by -i
limit 1;
