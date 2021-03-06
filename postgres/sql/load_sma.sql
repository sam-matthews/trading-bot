/*

  load_sma.sql
  Sam Matthews
  5th May 2020

  Script to load OHLC and SMA 6 and 12 data into intermediate table.

  Load chosen data into atomic data.
  Rules:
    - Based on latest dtae in table.
    - SMA6 is above SMA12.
    - Open is between SMA 6 and SMA 12.
    - Close is between SMA6 and SMA12.

The above assumes the price is between the SMA6 ansd SMA12. The assumption is the trend is going up.

We don't look at stocks which have open or close above SMA6. This may change, I may want stocks which are between the SMA 6 and SMA 12.

CUrrnetly this approach generates a reasonably low number of stocks. Potentially those stocks which may drop as quickly as they come up.


*/

TRUNCATE TABLE i_sma_6_12;

INSERT INTO i_sma_6_12
  SELECT
  a.stock,
  a.s_date,
  a.s_open,
  a.s_high,
  a.s_low,
  a.s_close,
  a.s_vol,
  b.a_sma AS "SMA6",
  c.a_sma AS "SMA12"
  FROM
    stock_daily a,
    a_sma_6 b,
    a_sma_12 c
  WHERE a.stock = b.stock
    AND a.stock = c.stock
    AND a.s_date = b.a_date
    AND a.s_date = c.a_date
;
