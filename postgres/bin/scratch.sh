#!/bin/zsh

# Used to test build functions.

APP_HOME="$HOME/dev/trading-bot"
POST_HOME=${APP_HOME}/postgres
POST_BIN=${POST_HOME}/bin
POST_CRE=${POST_HOME}/cre
POST_FUN=${POST_HOME}/fun
POST_SQL=${POST_HOME}/sql
POST_TAB=${POST_HOME}/tab

DBNAME="trading-bot"

WEEKLY_DAT="${HOME}/dev/alphavantage/dat/weekly"
#

#-- psql -d trading-bot -f $POST_TAB/s_higher_price_this_week.sql
#--psql -d trading-bot -f $POST_FUN/c-close-above-prev-close.sql
#psql -d trading-bot -t -c "SELECT FROM c_close_above_prev_close()"

c_green_candle() {
  psql -d trading-bot -f $POST_TAB/c_green_candles.sql
  psql -d trading-bot -f $POST_SQL/green-candles.sql
}

c_week_on_week_price_increase() {


  echo "Create table"
  psql -d trading-bot << EOF

    DROP TABLE IF EXISTS s_stock_rank_by_week;
    CREATE TABLE IF NOT EXISTS s_stock_rank_by_week
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
EOF

  psql -d trading-bot << EOF
    INSERT INTO s_stock_rank_by_week
      SELECT *, ROW_NUMBER() OVER (PARTITION BY stock ORDER BY s_date) AS week_id
      FROM stock_weekly;
EOF


  psql -d trading-bot << EOF

    SELECT * FROM s_stock_rank_by_week WHERE stock = 'AAPL' ORDER BY s_week_id DESC LIMIT 200;

EOF
}

c_prev_week() {

  psql -d ${DBNAME} -f ${POST_TAB}/s_prev_week.tab
  psql -d ${DBNAME} -f ${POST_TAB}/c_prev_week.tab
  psql -d ${DBNAME} -c "truncate table s_prev_week"

  echo "Loading staging data for previous week data."
  for STOCK in `ls -1 ${WEEKLY_DAT}`
  do
    # echo the Stock name. Trim the extention off.
    T_STOCK="${STOCK%%.*}"

    psql -d ${DBNAME} << EOF > /dev/null

      INSERT INTO s_prev_week
      WITH ordered AS
      (
        SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY stock ORDER BY s_date) AS week_id
        FROM stock_weekly
        WHERE stock = '$T_STOCK'
      )

      SELECT
        ordered.*,
        LAG(s_close) OVER (ORDER BY s_date) previous_close
      FROM
        ordered
      ORDER BY s_date DESC LIMIT 1
      ;

EOF
  done

  echo "Moving stocks which have increaed in the prev week."

  psql -d ${DBNAME} << EOF

  INSERT INTO c_prev_week
    SELECT * FROM s_prev_week WHERE s_close > s_prev_close;

EOF
}

c_prev_month() {
  psql -d ${DBNAME} << EOF

      -- INSERT INTO s_prev_week
      WITH ordered AS
      (
        SELECT
        *,
        ROW_NUMBER() OVER (PARTITION BY stock ORDER BY s_date DESC) AS week_id
        FROM stock_weekly
        WHERE stock = 'AAPL'
        ORDER BY stock,s_date
      )

      SELECT
        ordered.*,
        LAG(s_close,4) OVER (ORDER BY s_date) prev_mth_close
      FROM
        ordered
      ORDER BY stock, s_date DESC
      ;

EOF
}

prev_month_test () {
  psql -d ${DBNAME} << EOF
    DROP TABLE s_stock_id;
    CREATE TABLE s_stock_id AS
    SELECT
      *,
      ROW_NUMBER() OVER (PARTITION BY stock ORDER BY s_date DESC) AS week_id
      FROM stock_weekly
      -- WHERE stock = 'AAPL'
      ORDER BY stock,s_date;

    DROP TABLE s_stock_lag_mth;
    CREATE TABLE s_stock_lag_mth AS
    SELECT
        *,
        LAG(s_close,2) OVER (ORDER BY stock, s_date) previous_month
      FROM
        s_stock_id
      ;

    DROP TABLE c_prev_month;
    CREATE TABLE c_prev_month AS
    SELECT * FROM s_stock_lag_mth WHERE week_id = 1 AND s_close >previous_month;

EOF
}

summary() {
  psql -d ${DBNAME} << EOF

  SELECT a.*, b.s_prev_close, c.previous_month
  FROM c_green_candles a, c_prev_week b, c_prev_month c
  WHERE a.stock=b.stock
    AND a.stock=c.stock
    AND b.stock=c.stock;
EOF
}

#
# MAIN
#

# c_green_candle
# c_week_on_week_price_increase
# c_prev_week
# c_prev_month
prev_month_test

summary

