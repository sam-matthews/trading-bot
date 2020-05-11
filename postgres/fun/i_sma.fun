CREATE OR REPLACE FUNCTION i_sma() RETURNS VOID AS $$

DECLARE

  ref   RECORD;

BEGIN

  RAISE NOTICE 'Running data into i_sma_temp_1';

  TRUNCATE TABLE i_sma_temp_1;

  INSERT INTO i_sma_temp_1
  SELECT
    i_stock,
    i_date,
    rank() over (partition by i_stock order by i_date ASC) as i_rank,
    i_open,
    i_close,
    i_sma6,
    i_sma12
  FROM
    i_sma_6_12;

  RAISE NOTICE 'Running data into i_sma_temp_2';

  TRUNCATE TABLE i_sma_temp_2;

  FOR ref IN SELECT DISTINCT i_stock FROM i_sma_6_12 ORDER BY i_stock LOOP

    raise notice 'INSERTING STOCK: %', ref.i_stock;

    INSERT INTO i_sma_temp_2
    SELECT
      i_stock, i_date, i_rank, i_open, i_close, i_sma6, i_sma12,
      LAG(i_open,1)   OVER (ORDER BY i_rank) open_1,
      LAG(i_open,2)   OVER (ORDER BY i_rank) open_2,
      LAG(i_open,3)   OVER (ORDER BY i_rank) open_3,
      LAG(i_close,1)  OVER (ORDER BY i_rank) close_1,
      LAG(i_close,2)  OVER (ORDER BY i_rank) close_2,
      LAG(i_close,3)  OVER (ORDER BY i_rank) close_3,
      LAG(i_sma6,1)   OVER (ORDER BY i_rank) sma6_1,
      LAG(i_sma6,2)   OVER (ORDER BY i_rank) sma6_2,
      LAG(i_sma6,3)   OVER (ORDER BY i_rank) sma6_3,
      LAG(i_sma12,1)  OVER (ORDER BY i_rank) sma12_1,
      LAG(i_sma12,2)  OVER (ORDER BY i_rank) sma12_2,
      LAG(i_sma12,3)  OVER (ORDER BY i_rank) sma12_3
    FROM
      i_sma_temp_1
    WHERE 1=1
      AND i_stock = ref.i_stock
    ORDER BY i_stock, i_rank DESC;

  END LOOP;

END;

$$ LANGUAGE plpgsql;
