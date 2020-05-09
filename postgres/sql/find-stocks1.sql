-- SELECT i_stock, i_date, sma12_1, sma6_1, i_sma_12, i_sma_6
SELECT
  i_stock,
  i_date,
  i_sma_6,
  i_sma_12,
  i_sma6_1,
  i_sma12_1
FROM i_sma_temp_2
WHERE 1=1
  AND i_sma12_1 > i_sma6_1 AND i_sma_12 < i_sma_6
  AND i_date = (SELECT max(i_date) FROM i_sma_temp_2)
ORDER BY  i_date DESC
;
