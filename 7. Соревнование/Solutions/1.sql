DROP TABLE IF EXISTS space_investment_per_country, USA_capacity, RUS_capacity, 
                     GER_capacity, CHN_capacity, FRA_capacity CASCADE;

/* посчитать текущую инвестицию в детали, 
которая для каждой отдельной детали равна СТОИМОСТЬ_ДЕТАЛИ * СТАДИЯ_ИЗГОТОВЛЕНИЯ. 
Стадии изготовления указаны в процентах. 
В отчёте требуется указать суммарную инвестицию в детали для космических кораблей 
(Пример: если деталь стоит 1000 и готова на 76%, 
то на данный момент детали обошлось США в 760 монет).
*/
CREATE TABLE space_investment_per_country AS (
 SELECT country, SUM(invest) as total_invest
 FROM ((SELECT city_id, SUM(cost * (stage / 100)) AS invest
     FROM (SELECT Spaceship_part_in_town.id, city_id, cost, stage
        FROM Spaceship_part_in_town
        JOIN Spaceship_part
        ON Spaceship_part.id = Spaceship_part_in_town.spaceship_part_id
          ) AS H1 -- собрали данные для подсчета инвестиций
     GROUP BY city_id
    ) AS H2 -- инвестиции на уровне города
       JOIN Town ON Town.id = H2.city_id
      ) AS H -- джоин, чтобы группировать по странам
 GROUP BY country
 ORDER BY total_invest
);

/*
посчитать, сколько кораблей каждого типа сможет построить США, 
если решить делать корабли только одного вида 
(Учитываются только детали, которые уже находятся в производстве)
*/
CREATE TABLE USA_capacity AS (
 SELECT spaceship, MIN(CASE WHEN number_of_parts IS NULL THEN 0
                      ELSE number_of_parts
                    END / amount) AS ship_capacity
    FROM ((SELECT spaceship_part_id, COUNT(spaceship_part_id) AS number_of_parts
        FROM (SELECT spaceship_part_id, strana
           FROM (SELECT spaceship_part_id, Town.country AS strana
              FROM Spaceship_part_in_town
              JOIN Town
              ON Spaceship_part_in_town.city_id = Town.id) AS H11 -- детали во всех странах
           WHERE strana = 'США'
             ) AS H1 -- детали в США
        GROUP BY spaceship_part_id) AS H -- детали данного типа в США
        FULL OUTER JOIN Spaceship_required_part
        ON Spaceship_required_part.Spaceship_part = H.spaceship_part_id
          )
    GROUP BY spaceship
);

/*
посчитать такие же метрики для других стран
*/
CREATE TABLE RUS_capacity AS (
 SELECT spaceship, MIN(CASE WHEN number_of_parts IS NULL THEN 0
                      ELSE number_of_parts
                    END / amount) AS ship_capacity
    FROM ((SELECT spaceship_part_id, COUNT(spaceship_part_id) AS number_of_parts
        FROM (SELECT spaceship_part_id, strana
           FROM (SELECT spaceship_part_id, Town.country AS strana
              FROM Spaceship_part_in_town
              JOIN Town
              ON Spaceship_part_in_town.city_id = Town.id) AS H11 -- детали во всех странах
           WHERE strana = 'Россия'
             ) AS H1 -- детали в РФ
        GROUP BY spaceship_part_id) AS H -- детали данного типа в РФ
        FULL OUTER JOIN Spaceship_required_part
        ON Spaceship_required_part.Spaceship_part = H.spaceship_part_id
          )
    GROUP BY spaceship
);

CREATE TABLE GER_capacity AS (
 SELECT spaceship, MIN(CASE WHEN number_of_parts IS NULL THEN 0
                      ELSE number_of_parts
                    END / amount) AS ship_capacity
    FROM ((SELECT spaceship_part_id, COUNT(spaceship_part_id) AS number_of_parts
        FROM (SELECT spaceship_part_id, strana
           FROM (SELECT spaceship_part_id, Town.country AS strana
              FROM Spaceship_part_in_town
              JOIN Town
              ON Spaceship_part_in_town.city_id = Town.id) AS H11 -- детали во всех странах
           WHERE strana = 'Германия'
             ) AS H1 -- детали в Германии
        GROUP BY spaceship_part_id) AS H -- детали данного типа в Германии
        FULL OUTER JOIN Spaceship_required_part
        ON Spaceship_required_part.Spaceship_part = H.spaceship_part_id
          )
    GROUP BY spaceship
);

CREATE TABLE CHN_capacity AS (
 SELECT spaceship, MIN(CASE WHEN number_of_parts IS NULL THEN 0
                      ELSE number_of_parts
                    END / amount) AS ship_capacity
    FROM ((SELECT spaceship_part_id, COUNT(spaceship_part_id) AS number_of_parts
        FROM (SELECT spaceship_part_id, strana
           FROM (SELECT spaceship_part_id, Town.country AS strana
              FROM Spaceship_part_in_town
              JOIN Town
              ON Spaceship_part_in_town.city_id = Town.id) AS H11 -- детали во всех странах
           WHERE strana = 'Китай'
             ) AS H1 -- детали в Китае
        GROUP BY spaceship_part_id) AS H -- детали данного типа в Китае
        FULL OUTER JOIN Spaceship_required_part
        ON Spaceship_required_part.Spaceship_part = H.spaceship_part_id
          )
    GROUP BY spaceship
);

CREATE TABLE FRA_capacity AS (
 SELECT spaceship, MIN(CASE WHEN number_of_parts IS NULL THEN 0
                      ELSE number_of_parts
                    END / amount) AS ship_capacity
    FROM ((SELECT spaceship_part_id, COUNT(spaceship_part_id) AS number_of_parts
        FROM (SELECT spaceship_part_id, strana
           FROM (SELECT spaceship_part_id, Town.country AS strana
              FROM Spaceship_part_in_town
              JOIN Town
              ON Spaceship_part_in_town.city_id = Town.id) AS H11 -- детали во всех странах
           WHERE strana = 'France'
             ) AS H1 -- детали во Франции
        GROUP BY spaceship_part_id) AS H -- детали данного типа во Франции
        FULL OUTER JOIN Spaceship_required_part
        ON Spaceship_required_part.Spaceship_part = H.spaceship_part_id
          )
    GROUP BY spaceship
);

/*
Не успели по-человечески вывод оформить, но ответ написали ручками и селектами
*/
SELECT * from space_investment_per_country
--SELECT * from USA_capacity
--SELECT * from RUS_capacity
--SELECT * from GER_capacity
--SELECT * from CHN_capacity
--SELECT * from FRA_capacity
