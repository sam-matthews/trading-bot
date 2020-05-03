#!/bin/zsh

# load-data.sh
# 3rd May 2020
# Sam Matthews

# Parameters
APP_HOME="${HOME}/dev/trading-bot"
POST_HOME="${APP_HOME}/postgres"
POST_SQL="${POST_HOME}/sql"
POST_TAB="${POST_HOME}/tab"

WEEKLY_DAT="$HOME/dev/alphavantage/dat/weekly"

DBNAME="trading-bot"

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

psql -d ${DBNAME} -c "INSERT INTO c_prev_week SELECT * FROM s_prev_week WHERE s_close > s_prev_close"

