CREATE OR REPLACE FUNCTION a_sma() RETURNS VOID AS $$

DECLARE

  ref   RECORD;

BEGIN

  RAISE NOTICE 'Calculating SMA Data';

  TRUNCATE TABLE a_sma_daily_6;

  FOR ref IN SELECT DISTINCT stock FROM stock_daily
  LOOP

    INSERT INTO a_sma_daily_6 (stock, a_date, a_sma)
    SELECT
      stock, s_date,
      ROUND(AVG(s_close) OVER(ORDER BY s_date ROWS BETWEEN (5) PRECEDING AND CURRENT ROW),2)
    FROM stock_daily
    WHERE 1=1
      AND stock = ref.stock
    ORDER BY s_date;

    INSERT INTO a_sma_daily_12 (stock, a_date, a_sma)
    SELECT
      stock, s_date,
      ROUND(AVG(s_close) OVER(ORDER BY s_date ROWS BETWEEN (11) PRECEDING AND CURRENT ROW),2)
    FROM stock_daily
    WHERE 1=1
      AND stock = ref.stock
    ORDER BY s_date;

  /*
    INSERT INTO a_sma_weekly_6 (stock, a_date, a_sma)
    SELECT
      stock, s_date,
      ROUND(AVG(s_close) OVER(ORDER BY s_date ROWS BETWEEN (5) PRECEDING AND CURRENT ROW),2)
    FROM stock_weekly
    WHERE 1=1
      AND stock = ref.stock
    ORDER BY s_date;

    INSERT INTO a_sma_weekly_12 (stock, a_date, a_sma)
    SELECT
      stock, s_date,
      ROUND(AVG(s_close) OVER(ORDER BY s_date ROWS BETWEEN (11) PRECEDING AND CURRENT ROW),2)
    FROM stock_weekly
    WHERE 1=1
      AND stock = ref.stock
    ORDER BY s_date;
  */

  END LOOP;
END;

$$ LANGUAGE plpgsql;
