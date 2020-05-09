/*

  green_candles.sql
  Sam Matthews
  2nd May 2020

  This script will identify all candles which this week was a gree candle or positive. This can be used in a function later, plus it is very quick to run. Bonus.

*/

TRUNCATE TABLE c_green_candles;

WITH ordered AS
(
  SELECT
  *,
  ROW_NUMBER() OVER (PARTITION BY stock ORDER BY s_date DESC) AS week_id
  FROM stock_weekly
)

INSERT INTO c_green_candles
SELECT stock, s_date, s_open, s_high, s_low, s_close
FROM ordered
WHERE week_id = 1 AND s_open < s_close;
