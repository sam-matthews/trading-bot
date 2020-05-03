/*

  sma.fun
  Sam Matthews
  10 October 2018

  Function to output SMA calculations. Input is anaytic_lkp and price data.
  Output will (eventually into a seperate table).

  Useage:
  1. Compile function.
  2. SELECT sma(<fund>);

*/

CREATE OR REPLACE FUNCTION c_close_above_prev_close() RETURNS VOID AS $$

DECLARE
  ref RECORD;
BEGIN

  -- Insert into table which will provide a rank by id. This will assist with determining how data gets loaded.

  INSERT INTO s_stock_rank_by_week
    SELECT *, ROW_NUMBER() OVER (PARTITION BY stock ORDER BY s_date) AS week_id
    FROM stock_weekly
    WHERE stock = ref.stock; -- We include the stock.


  -- GET the current weekly data for all stocks load them into atomic table is close from last week
  -- is lower than close from this week.

  FOR ref IN

    SELECT DISTINCT stock FROM stock_weekly WHERE stock = 'AAPL'

    LOOP

      INSERT INTO s_stock_rank_by_week
      SELECT *, ROW_NUMBER() OVER (PARTITION BY stock ORDER BY s_date) AS week_id
      FROM stock_weekly
      WHERE stock = ref.stock; -- We include the stock.

    END LOOP;

END;
$$ LANGUAGE plpgsql;
