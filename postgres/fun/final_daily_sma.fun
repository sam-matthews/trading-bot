CREATE OR REPLACE FUNCTION final_daily_sma() RETURNS VOID AS $$

BEGIN

  RAISE NOTICE 'Determining favourite stocks based on daily data';

  TRUNCATE TABLE final_daily_sma;

  INSERT INTO final_daily_sma
  SELECT * FROM i_sma_temp_2
  WHERE 1=1
    AND i_sma12_1 > i_sma6_1 AND i_sma_12 < i_sma_6
    AND i_date = (SELECT max(i_date) FROM i_sma_temp_2)
  ;

END;

$$ LANGUAGE plpgsql;
