-- Пункт 1:

with RECURSIVE prod AS (
 SELECT 1 AS i, num AS last_digits
 FROM nums 
 WHERE id = 1
    
 UNION ALL
    
 SELECT i+1, (last_digits * 
    (SELECT num 
     FROM nums 
     WHERE id = i+1)) % 1000 
 FROM prod 
 WHERE i < (SELECT COUNT(*) FROM nums)
)

SELECT CASE last_digits
        WHEN 0 THEN '000'
    END CASE
FROM prod
WHERE i = (SELECT COUNT(*) FROM nums);

-- Пункт 2:

WITH RECURSIVE report AS
 (SELECT 1 AS mese,
   0 :: bigint AS inizio, -- считаем, что в начале года есть 0 единиц продукта, нет?

   (SELECT SUM(amount)
    FROM factory
    WHERE month = 1) AS fine,

   (SELECT SUM(amount)
    FROM factory
    WHERE month = 1) AS bilancio
  
  UNION ALL 
  
   SELECT mese + 1,
   fine,
   fine +
   (SELECT SUM(amount)
    FROM factory
    WHERE month = mese + 1),
   (SELECT SUM(amount)
    FROM factory
    WHERE month = mese + 1)
  FROM report
  WHERE mese < 12 )
  
SELECT * FROM report;

-- Пункт 3 (хотел избавиться от повторяющихся кусков с помощью функций, не получилось, сдался)

WITH RECURSIVE drunk AS
 (SELECT 0 AS i,
   0 :: bigint AS ryan,
   0 :: bigint AS livia,
   0 :: bigint AS felix,
   0 :: bigint AS vulcan,
   0 :: bigint AS wyvern
  
  UNION ALL 
  
  SELECT i + 1,
   ryan +
   (SELECT COALESCE(SUM(drinks), 0) - ((ryan != 0)::int)
    FROM bar
    WHERE (customer = 1)
       AND (date <= (timestamp '1921-05-08 21:00:00' + ((i + 1) * interval '1 hour')))
             AND (date > (timestamp '1921-05-08 21:00:00' + (i * interval '1 hour')))
      
   ),
   livia +
   (SELECT COALESCE(SUM(drinks), 0) - ((livia != 0)::int)
    FROM bar
    WHERE (customer = 2)
       AND (date <= (timestamp '1921-05-08 21:00:00' + ((i + 1) * interval '1 hour')))
             AND (date > (timestamp '1921-05-08 21:00:00' + (i * interval '1 hour')))
      
   ),
         felix +
   (SELECT COALESCE(SUM(drinks), 0) - ((felix != 0)::int)
    FROM bar
    WHERE (customer = 3)
       AND (date <= (timestamp '1921-05-08 21:00:00' + ((i + 1) * interval '1 hour')))
             AND (date > (timestamp '1921-05-08 21:00:00' + (i * interval '1 hour')))
      
   ),
    vulcan +
   (SELECT COALESCE(SUM(drinks), 0) - ((vulcan != 0)::int)
    FROM bar
    WHERE (customer = 4)
       AND (date <= (timestamp '1921-05-08 21:00:00' + ((i + 1) * interval '1 hour')))
             AND (date > (timestamp '1921-05-08 21:00:00' + (i * interval '1 hour')))
      
   ),
    wyvern +
   (SELECT COALESCE(SUM(drinks), 0) - ((wyvern != 0)::int)
    FROM bar
    WHERE (customer = 5)
       AND (date <= (timestamp '1921-05-08 21:00:00' + ((i + 1) * interval '1 hour')))
             AND (date > (timestamp '1921-05-08 21:00:00' + (i * interval '1 hour'))) 
   )
  FROM drunk
  WHERE i < 9 ),
  
 sober_rank AS (
  SELECT 'Ryan' AS sober,
   (SELECT ryan
    FROM drunk
    WHERE i = 9) AS drink_index
  
  UNION ALL 
  SELECT 'Livia' AS sober,
   (SELECT livia
    FROM drunk
    WHERE i = 9) AS drink_index
  
  UNION ALL 
  SELECT 'Felix' AS sober,
   (SELECT felix
    FROM drunk
    WHERE i = 9) AS drink_index
  
  UNION ALL 
  SELECT 'Vulcan' AS sober,
   (SELECT vulcan
    FROM drunk
    WHERE i = 9) AS drink_index
  
  UNION ALL 
  SELECT 'Wyvern' AS sober,
   (SELECT wyvern
    FROM drunk
    WHERE i = 9) AS drink_index
 )
    
    
SELECT * FROM sober_rank
ORDER BY drink_index DESC

-- Пункт 4 (маркдаун не хранит пробелы как есть):

-- это +- поиск в глубину в графе-пути, в котором в какой-то момент, возможно, есть ветвление
-- если есть, надо найти итальянца на том же уровне, что и Вито, но в другой ветке

WITH RECURSIVE decapitare AS
    -- i - хранитель поколения, first_id - отец рассматриваемого итальянца
 (SELECT 1 :: bigint AS i,
   0 :: bigint AS first_id
  
  UNION ALL 
  
 SELECT i + 1,
     (SELECT id FROM Italians 
   WHERE gender = 'm'
        AND parent = first_id
      ORDER BY id
   LIMIT 1)
 FROM decapitare
 WHERE first_id IS NOT NULL 
 ),
    
 -- У всех мужчин в семье Феллини был только 1 сын, кроме, быть может, одного.
 possible_dub AS
 (SELECT 1 :: bigint AS j,
   0 ::bigint AS last_id
  
  UNION ALL 
  
  SELECT j + 1,
   (SELECT id
    FROM Italians
    WHERE gender = 'm'
     AND parent = last_id
    ORDER BY id DESC
    LIMIT 1)
  FROM possible_dub
  WHERE last_id IS NOT NULL
 )
  
  
SELECT id, COALESCE(name, 'его вообще нет'), parent
FROM Italians
WHERE (id = (SELECT first_id 
    FROM decapitare 
    WHERE i = (SELECT j FROM possible_dub
      WHERE (last_id = (SELECT id FROM Italians 
            WHERE name = 'Vito Fellini')
         ) 
        ) 
   )
   )
   OR (id = (SELECT last_id FROM possible_dub
    WHERE j = (SELECT i FROM decapitare 
      WHERE (first_id = (SELECT id FROM Italians 
            WHERE name = 'Vito Fellini')
         ) 
        ) 
   )
   )
