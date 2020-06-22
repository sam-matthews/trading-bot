CREATE OR REPLACE FUNCTION five_day_growth() RETURNS VOID AS $$

DECLARE

  ref   RECORD;

BEGIN

  TRUNCATE TABLE s_5_day_growth;

  FOR ref IN SELECT DISTINCT stock FROM stock_daily ORDER BY 1 LOOP

    raise notice 'INSERTING STOCK: %', ref.stock;

    INSERT INTO s_5_day_growth
      WITH week_growth AS (SELECT stock, s_date, s_close, LAG(s_close,5) OVER (ORDER BY s_date) s_close_start FROM stock_daily WHERE stock = ref.stock)
      SELECT stock, s_date, s_close, s_close_start, ROUND(((s_close - s_close_start) / s_close_start) * 100,2) growth FROM week_growth ORDER BY s_date DESC;
  END LOOP;

END;

$$ LANGUAGE plpgsql;
