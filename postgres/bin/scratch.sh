#!/bin/zsh

# Used to test build functions.

APP_HOME="$HOME/dev/trading-bot"
POST_HOME=${APP_HOME}/postgres
POST_BIN=${POST_HOME}/bin
POST_CRE=${POST_HOME}/cre
POST_FUN=${POST_HOME}/fun
POST_SQL=${POST_HOME}/sql
POST_TAB=${POST_HOME}/tab


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

#
# MAIN
#

c_green_candle
# c_week_on_week_price_increase

