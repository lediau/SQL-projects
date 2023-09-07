DROP FUNCTION IF EXISTS kid_gene;

CREATE FUNCTION kid_gene(m int, mg int, d int, dg int) 
RETURNS int 
LANGUAGE plpgsql 
AS 
$$
DECLARE 
  bin int = 128;
  kg int = 0;
BEGIN
    while bin > 0 LOOP
        if m <= d THEN 
   if (mg & bin) != 0 OR (dg & bin) != 0 THEN 
    kg = kg + (mg & bin);
   else 
    kg = kg + bin;
   END if;
        else
   kg = kg + (mg & bin);
  END if;
 bin = bin / 2;
 END LOOP;
 return kg;
END;
$$;

with mating (kid_id, mom, mom_gene, dad, dad_gene, kid_gene) AS (
 SELECT m.id + d.id, m.name, m.gene, d.name, d.gene, kid_gene(m.id, m.gene, d.id, d.gene) 
 FROM (
    (SELECT trooper.id, trooper.name, trooper.gene
  FROM (SELECT MIN(id) as id, gene 
     FROM trooper 
     WHERE sex = false 
     GROUP BY gene) AS h
     INNER JOIN trooper
     ON trooper.id = h.id
    ) AS m 
    CROSS JOIN 
    (SELECT id, name, gene
  FROM trooper 
  WHERE sex = true
  ) AS d
 )
)

SELECT * 
FROM mating
ORDER BY -kid_gene, kid_id;
