-- RUN 8 TIMES TO GET CORRECT ANSWER, LOL
-- TO BE MORE PRECISE, RUN THE CODE UNTIL THE POWER OF THE LAST (go)TRONE BECOMES NON-ZERO
-- OR IF YOU LIKE TO COUNT, RUN THE CODE AS MANY TIMES AS MANY (GO) ARE IN THE LAST TRONE (+-1)

with hel as (
select parent_gotrone_id, sum(power) as s
from gotrones_db
group by parent_gotrone_id)

UPDATE gotrones_db
set power = hel.s from hel
where gotrone_id = hel.parent_gotrone_id;

select * from gotrones_db
order by -power
limit 3;

-------------------------

-- select * from gotrones_db 
-- where parent_gotrone_id = -1
