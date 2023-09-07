-- Задание 4:

SELECT table_n as bad_table
FROM
 (SELECT table_n,
   SUM(ASCII(card)) AS card_sum,
   511030 AS normal_sum
  FROM TwentyOneTables
  GROUP BY table_n) AS new_table
WHERE card_sum != normal_sum

-- Задание 3:

DROP TABLE IF EXISTS card_values;

CREATE TABLE card_values (
 card_type varchar(1),
 card_value double PRECISION
);

INSERT INTO card_values VALUES
 ('J', -1), ('Q', -1),('K', -1),('A', -1),
 ('3', 1), ('4', 1), ('6', 1),
 ('5', 1.5),
 ('9', -0.5),
 ('0', -1),
 ('2', 0.5), ('7', 0.5),
 ('8', 0);

with RECURSIVE max_counter AS (
 SELECT
  0 :: bigint AS i,
  table_n AS game,
  NULL :: VARCHAR(2) AS card_on_table,
  0 :: double PRECISION AS counter
 
 FROM
  (SELECT *
   FROM TwentyOneTables
   ORDER BY table_n, id
   LIMIT 1) AS card_i
 
 UNION ALL
 
 SELECT
  i+1,
  (SELECT table_n
   FROM TwentyOneTables
   ORDER BY table_n, id
   LIMIT 1 OFFSET i
  ),
  (SELECT card
   FROM TwentyOneTables
   ORDER BY table_n, id
   LIMIT 1 OFFSET i
  ),
  ((SELECT table_n
    FROM TwentyOneTables
    ORDER BY table_n, id
    LIMIT 1 OFFSET i) = game)::int*(counter)
  +
   (SELECT card_value
    FROM (SELECT * FROM TwentyOneTables
    JOIN card_values ON (card_type = right(card, 1))) AS together
    ORDER BY table_n, id
    LIMIT 1 OFFSET i)
 FROM max_counter
 WHERE i < (SELECT COUNT(id) FROM TwentyOneTables)
)

SELECT MAX(counter) AS max_counter
FROM max_counter

-- Задание 2:

WITH RECURSIVE winner AS
 (SELECT 0 :: bigint AS i,
   NULL ::text AS game_type,
   NULL ::text AS player,
   0 ::bigint AS round_win,
   0 ::bigint AS current_sum
  
  UNION ALL 
  
  SELECT i + 1,
   (SELECT event_type
    FROM (SELECT PokerEvent.id AS id, event_type, executor, value
       FROM PokerEvent
       LEFT JOIN Bets ON (PokerEvent.id = poker_event_id)
       ORDER BY PokerEvent.id ASC) AS together
       WHERE ID = i + 1
   ),
   (SELECT executor
    FROM (SELECT PokerEvent.id AS id, event_type, executor, value
       FROM PokerEvent
       LEFT JOIN Bets ON (PokerEvent.id = poker_event_id)
       ORDER BY PokerEvent.ID ASC) AS together
    WHERE ID = i + 1
   ), 
   COALESCE((SELECT -1 * value 
       FROM (SELECT PokerEvent.id as id, event_type, executor, value 
       FROM PokerEvent 
       LEFT JOIN Bets on (PokerEvent.id = poker_event_id) 
       ORDER BY PokerEvent.id ASC) AS together 
       WHERE id = i + 1
      ), -1 * current_sum
     ),
      current_sum + COALESCE((SELECT -1 * value 
       FROM (SELECT PokerEvent.id as id, event_type, executor, value 
          FROM PokerEvent 
          LEFT JOIN Bets on (PokerEvent.id = poker_event_id) 
          ORDER BY PokerEvent.id ASC) AS together
       WHERE id = i + 1), 
         -1 * current_sum)
  FROM winner
  WHERE i < (SELECT COUNT(*) 
       FROM (SELECT PokerEvent.id AS id, event_type, executor, value
          FROM PokerEvent
       LEFT JOIN BETS ON (PokerEvent.id = poker_event_id)
       ORDER BY PokerEvent.id ASC) AS together
      )
 )

SELECT player, win + 1000 AS casino_revenue
FROM (SELECT player, SUM(round_win) AS win
   FROM winner
   GROUP BY player
   ORDER BY win DESC
   LIMIT 1) AS rich
