CREATE OR REPLACE FUNCTION i_sma() RETURNS VOID AS $$

BEGIN

  INSERT INTO i_sma_6_12
  SELECT
  a.stock,
  a.s_date,
  a.s_open,
  a.s_high,
  a.s_low,
  a.s_close,
  a.s_vol,
  b.a_sma "SMA6",
  c.a_sma "SMA12"
  FROM
    stock_daily a,
    a_sma_daily_6 b,
    a_sma_daily_12 c
  WHERE a.stock = b.stock
    AND a.stock = c.stock
    AND a.s_date = b.a_date
    AND a.s_date = c.a_date
  ORDER BY stock, s_date;

END;

$$ LANGUAGE plpgsql;
