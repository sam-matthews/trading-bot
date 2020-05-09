#!/bin/zsh

# load-data.sh
# 3rd May 2020
# Sam Matthews

# Parameters
APP_HOME="${HOME}/dev/trading-bot"
POST_HOME="${APP_HOME}/postgres"
POST_SQL="${POST_HOME}/sql"
POST_TAB="${POST_HOME}/tab"

monthLY_DAT="$HOME/dev/alphavantage/dat/monthly"

DBNAME="trading-bot"

psql -d ${DBNAME} -f ${POST_TAB}/s_prev_month.tab
psql -d ${DBNAME} -f ${POST_TAB}/c_prev_month.tab
psql -d ${DBNAME} -c "truncate table s_prev_month"

echo "Loading staging data for previous month data."

for STOCK in `ls -1 ${monthLY_DAT}`
do
  # echo the Stock name. Trim the extention off.
  T_STOCK="${STOCK%%.*}"

  psql -d ${DBNAME} << EOF > /dev/null

    INSERT INTO s_prev_month
    WITH ordered AS
    (
      SELECT
      *,
      ROW_NUMBER() OVER (PARTITION BY stock ORDER BY s_date) AS month_id
      FROM stock_weekly
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

echo "Moving stocks which have increaed in the prev month."

psql -d ${DBNAME} -c "INSERT INTO c_prev_month SELECT * FROM s_prev_month WHERE s_close > s_prev_close"

