/*

    s_higher_price_this_week.sql
    3rd May 2020
    Sam Matthews

    Script will create a table called stock. This table will hold all core stock daily stock data.
    This should be the largest CORE data.
*/

DROP TABLE IF EXISTS s_higher_price_this_week;
CREATE TABLE IF NOT EXISTS s_higher_price_this_week
(
    stock   CHAR(10),
    s_date  TIMESTAMP,
    s_open  NUMERIC,
    s_high   NUMERIC,
    s_low  NUMERIC,
    s_close NUMERIC,
    s_vol   BIGINT,
    s_week_id INTEGER,
    s_prev_close NUMERIC
);
