-- Пункт 1:

select breed, count(breed) as occur, avg(milk_per_second) as milk_per_group
from Cow
group by breed

having count(breed) > 3;

-- Пункт 2:

SELECT
  generate_series FROM GENERATE_SERIES(1, 100)
WHERE
  NOT EXISTS(SELECT name FROM Dog WHERE name = generate_series)

-- Пункт 3 (не понял, можно ли дослать если руки не дошли до него до дедлайна, но на всякий случай небесполезно разобраться):

ALTER TABLE Cat
DROP column IF EXISTS catGrade,
DROP column IF EXISTS f_breed;

AlTER TABLE Cat
ADD catGrade float,
ADD f_breed float,
ADD all_breeds float;

UPDATE Cat
SET f_breed = CASE
      WHEN breed = 'American' THEN 0.5
      WHEN breed = 'British' THEN 1.0
      WHEN breed = 'Munchkin' THEN 1.5
      WHEN breed = 'Bengal' THEN 3.0
      WHEN breed = 'Siberian' THEN 2.0
      END;

-- не знаю, как можно было сделать по-умному
UPDATE Cat
SET all_breeds = CASE
      WHEN breed = 'American' 
           THEN (SELECT count(breed) from Cat WHERE breed = 'American')
      WHEN breed = 'British' 
           THEN (SELECT count(breed) from Cat WHERE breed = 'British')
      WHEN breed = 'Munchkin' 
           THEN (SELECT count(breed) from Cat WHERE breed = 'Munchkin')
      WHEN breed = 'Bengal' 
           THEN (SELECT count(breed) from Cat WHERE breed = 'Bengal')
      WHEN breed = 'Siberian' 
           THEN (SELECT count(breed) from Cat WHERE breed = 'Siberian')
      END;

UPDATE Cat
SET catGrade = (sex*count*f_breed*f_breed*f_breed/age + 
               (1-sex)*f_breed*f_breed*count/age) /
               all_breeds;
      

SELECT name, catGrade from Cat
ORDER BY catGrade DESC

-- Пункт 4

ALTER TABLE Horse_type
RENAME COLUMN name TO breed;

SELECT
h1.name as First_partner, h2.name as Second_partner
FROM (SELECT Horse.name, Horse.height, Horse.sex, Horse.color, Horse.age, Horse.code, Horse_type.breed
      FROM Horse
      JOIN Horse_type
          ON SUBSTRING(Horse.code, 1, 3) = Horse_type.code) as h1
	
CROSS JOIN (SELECT Horse.name, Horse.height, Horse.sex, Horse.color, Horse.age, Horse.code, Horse_type.breed
            FROM Horse
            JOIN Horse_type
                ON SUBSTRING(Horse.code, 1, 3) = Horse_type.code) as h2
	
WHERE
    SUBSTRING(h1.code, 5, 2) < SUBSTRING(h2.code, 5, 2) AND -- с собой как бы нельзя:), а также убираем дубликатов
	NOT h1.sex = h2.sex AND -- LGBT..+ тоже нельзя
	ABS(h1.age - h2.age) <= 2 AND -- раз. возраст <= 2
	(
		h1.breed = h2.breed -- внутри одного типа, в т.ч. скаковых
	OR -- Ездовых можно скрещивать с пони только если разница в их росте не больше 20см
		(h1.breed = 'Ð•Ð·Ð´Ð¾Ð²Ð°Ñ' AND h2.breed = 'ÐŸÐ¾Ð½Ð¸' AND ABS(h1.height - h2.height) <= 20)
	OR  (h2.breed = 'Ð•Ð·Ð´Ð¾Ð²Ð°Ñ' AND h1.breed = 'ÐŸÐ¾Ð½Ð¸' AND ABS(h1.height - h2.height) <= 20)	
	
	OR -- Тяжеловесов можно скрещивать с ездовыми только в случае, если они одного окраса
	    (h1.breed = 'Ð•Ð·Ð´Ð¾Ð²Ð°Ñ' AND h2.breed = 'Ð¢ÑÐ¶ÐµÐ»Ð¾Ð²ÐµÑ' AND h1.color = h2.color)
	OR  (h2.breed = 'Ð•Ð·Ð´Ð¾Ð²Ð°Ñ' AND h1.breed = 'Ð¢ÑÐ¶ÐµÐ»Ð¾Ð²ÐµÑ' AND h1.color = h2.color)
	)
