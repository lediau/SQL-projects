with six_worst AS (
 SELECT COUNT(1) AS one_team, first_letter
 FROM (SELECT SUBSTRING(name, 1, 1) AS first_letter, name, id
    FROM Trooper) AS tg
 GROUP BY first_letter
 ORDER BY one_team
 LIMIT 6
),
worst_teams AS (
 SELECT tu.fl || v.first_letter AS team,
     tu.tm + v.one_team AS team_members
 FROM (SELECT t.first_letter || u.first_letter AS fl,
        t.one_team + u.one_team AS tm
    FROM six_worst AS t
    JOIN six_worst AS u
    ON t.first_letter < u.first_letter
 ) AS tu
 JOIN six_worst AS v
 ON v.first_letter < SUBSTRING(tu.fl, 1, 1) AND v.first_letter < RIGHT(tu.fl, 1)
 ORDER BY tm
),
scores AS (SELECT 1 AS score,
            t.team AS winner,
            t.team_members AS size
       FROM worst_teams AS t
       JOIN worst_teams AS u
       ON
   t.team_members > u.team_members AND SUBSTRING(t.team, 1, 1) != SUBSTRING(u.team, 1 ,1) AND SUBSTRING(t.team, 1 ,1) != SUBSTRING(u.team, 2 ,1) AND
   SUBSTRING(t.team, 1 ,1) != SUBSTRING(u.team, 3 ,1) AND SUBSTRING(t.team, 2 ,1) != SUBSTRING(u.team, 1 ,1) and
   SUBSTRING(t.team, 2 ,1) != SUBSTRING(u.team, 2 ,1) AND SUBSTRING(t.team, 2 ,1) != SUBSTRING(u.team, 3 ,1) and
   SUBSTRING(t.team, 3 ,1) != SUBSTRING(u.team, 1 ,1) AND SUBSTRING(t.team, 3 ,1) != SUBSTRING(u.team, 2 ,1) and
   SUBSTRING(t.team, 3 ,1) != SUBSTRING(u.team, 3 ,1)
      )

SELECT * FROM (
 SELECT prize_team 
 FROM (SELECT SUM(score) AS scores,
         winner AS prize_team,
         size
    FROM scores
    GROUP BY (winner, size)
    ORDER BY scores, size
    LIMIT 1
      ) AS pts
) AS h;
SELECT DISTINCT name
FROM Trooper
WHERE SUBSTRING(name, 1, 1) = 'E' OR 
      SUBSTRING(name, 1, 1) = 'K' OR 
   SUBSTRING(name, 1, 1) = 'S'
ORDER BY name
