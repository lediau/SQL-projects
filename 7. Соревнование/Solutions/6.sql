SELECT FLOOR(AVG(gene)) AS average, 
    PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY gene) AS median 
FROM trooper;

SELECT COUNT(sex) AS top_woman, 100 - COUNT(sex) AS top_man 
FROM (SELECT sex FROM trooper FETCH FIRST 100 ROWS ONLY) h
WHERE sex = false;

SELECT name AS common_name, COUNT(name) AS often 
FROM trooper
GROUP BY common_name
ORDER BY often DESC
LIMIT 1;
