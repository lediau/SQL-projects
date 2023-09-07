with stage_with_rows AS
 (SELECT city_id, stage, 
    ROW_NUMBER() OVER (PARTITION BY city_id ORDER BY city_id, stage) AS rownumber 
  FROM Spaceship_part_in_town 
     WHERE stage>=10),
  
counts AS
 (SELECT city_id, COUNT(1) AS counter
  FROM stage_with_rows 
  GROUP BY city_id),
  
medians AS 
 (SELECT stage_with_rows.city_id, stage, rownumber, counter 
     FROM stage_with_rows 
  JOIN counts ON counts.city_id=stage_with_rows.city_id
  GROUP BY stage_with_rows.city_id, stage, rownumber, counter
  HAVING (counter%2 = 0 AND rownumber BETWEEN FLOOR((counter+1)/2) 
                  AND FLOOR((counter+1)/2) +1) 
    OR (counter%2 <> 0 AND rownumber = (counter+1)/2)
 ),
    
city_median AS (SELECT city_id, AVG(stage) AS median 
    FROM medians
    GROUP BY city_id),
    
country_stage_with_rows AS (SELECT id, country, median, 
              ROW_NUMBER() OVER (PARTITION BY country ORDER BY country, median) AS rownumber 
       FROM Town 
       JOIN city_median ON city_median.city_id=Town.id),

counts_country AS
 (SELECT country, COUNT(1) AS counter
     FROM country_stage_with_rows 
  GROUP BY country),
  
country_medians AS (SELECT counts_country.country, median, rownumber, counter 
     FROM country_stage_with_rows 
     JOIN counts_country on counts_country.country=country_stage_with_rows.country
     GROUP BY counts_country.country, median, rownumber, counter
     HAVING (counter%2 = 0 AND rownumber BETWEEN FLOOR((counter+1)/2) AND FLOOR((counter+1)/2) +1)
                     OR (counter%2 <> 0 AND rownumber = (counter+1)/2))

SELECT country, AVG(median) 
FROM country_medians
GROUP BY country
ORDER BY country
