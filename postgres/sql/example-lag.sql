

WITH ordered AS
(
  SELECT
  *,
  ROW_NUMBER() OVER (PARTITION BY stock ORDER BY s_date) AS week_id
  FROM stock_weekly
  WHERE stock = 'AAPL'
)

SELECT
  ordered.*,
  LAG(s_close) OVER (ORDER BY s_date) previous_close
FROM
  ordered
ORDER BY s_date DESC LIMIT 1
WHERE week_id=1;
;
