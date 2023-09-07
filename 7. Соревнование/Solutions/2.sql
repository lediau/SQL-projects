DROP TABLE IF EXISTS Inspection;

SELECT city_id, Town.name AS city_name, COUNT(1) AS n_parts
INTO Inspection
FROM Spaceship_part_in_town 
JOIN Town
ON Town.id = city_id
WHERE Spaceship_part_in_town.stage>=10 
GROUP BY city_id, Town.name
ORDER BY city_id;

SELECT * FROM Inspection;

-- Python code

from itertools import permutations
import math

town = ["Moscow", "Berlin", "Washington", "Texas", "Dallas", "Beijing", "Paris"]
n_parts = [6679, 19905, 4472, 4359, 4458, 66579, 20008]

perms = permutations(list(range(7)))

max_respect = 0
shocks = 0
perm_m = []
for p in perms:
 insp = 5
 for j in range(0, 7):
  t1, t2, t3 = [(n_parts[p[k]] if k >= 0 else 0) for k in range(j - 2, j + 1)]
  if t3 > (t1 + t2) / 2:
   insp += 3 + math.log(t3 - min(t1, t2))
  else:
   insp -= 2
  if insp < 0:
   shocks += 1
 respect = (10 - shocks) * insp
 if respect > max_respect:
  max_respect = respect
  perm_m = p

print(math.ceil(max_respect), perm_m, sep=', ')
print([town[k] for k in perm_m])
