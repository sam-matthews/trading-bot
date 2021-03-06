#!/bin/zsh

# load-data.sh
# 3rd May 2020
# Sam Matthews

# History
# 20200510 SMM 0.1.1 Remove function to load SMA data from alphavantage.

# App

DAT_NAME="alphavantage"

# Parameters
APP_HOME="${HOME}/dev/projects/trading-bot"
POST_HOME="${APP_HOME}/postgres"
POST_SQL="${POST_HOME}/sql"
POST_BIN="${POST_HOME}/bin"

DAT_HOME="${HOME}/dev/projects/${DAT_NAME}/dat"
WEEKLY_DAT="${DAT_HOME}/weekly"
WEEKLY_SMA6_DAT="${DAT_HOME}/weekly-sma-6"
WEEKLY_SMA12_DAT="${DAT_HOME}/weekly-sma-12"
DAILY_DAT="${DAT_HOME}/daily"
DAILY_SMA6_DAT="${DAT_HOME}/SMA6"
DAILY_SMA12_DAT="${DAT_HOME}/SMA12"

DBNAME="trading-bot"

check_directories() {

  DIR_NAME=$1

  if [ ! -d "${DIR_NAME}" ]; then
    mkdir -p ${DIR_NAME}
    echo "Create directory: ${DIR_NAME}"
  fi
}

load-data() {

  DAT_TYPE=$1

  echo "Choosing to run in ${DAT_TYPE} mode."

  case ${DAT_TYPE} in

    daily)
      DAT_LOCATION=${DAILY_DAT}
      ATOMIC_TABLE="stock_daily"
      ;;

    weekly)
      DAT_LOCATION=${WEEKLY_DAT}
      ATOMIC_TABLE="stock_daily"
      ;;

    *)
      echo "ERROR: Type needs to be DAILY or WEEKLY"
      exit 10
      ;;

  esac

  STAGING_TABLE="s_stock"

  check_directories ${DAT_LOCATION}

  # TRUNCATE ATOMIC TABLE because we will do a FULL LOAD.
  psql -d ${DBNAME} -t -c "TRUNCATE TABLE ${ATOMIC_TABLE}" > /dev/null

  for STOCK in `ls -1 ${DAT_LOCATION}`
  do

    # echo the Stock name. Trim the extention off.
    T_STOCK="${STOCK%%.*}"
    echo "Loading: ${T_STOCK}"

    # Truncate s_stock
    psql -d ${DBNAME} -t -c "TRUNCATE TABLE ${STAGING_TABLE}" > /dev/null

    # Load stock into s_stock.
    psql -d ${DBNAME} -t -c "\COPY ${STAGING_TABLE} FROM ${DAT_LOCATION}/${STOCK} DELIMITER ',' CSV HEADER" > /dev/null

    # Load stock data into stock table.

    psql -d ${DBNAME} -t -c "INSERT INTO ${ATOMIC_TABLE} SELECT '${T_STOCK}', s_date, s_open, s_high, s_low, s_close, s_vol FROM s_stock" > /dev/null

  done

  # Generate growth data
  psql -d ${DBNAME} -t -c "SELECT FROM one_day_growth()" > /dev/null
  psql -d ${DBNAME} -t -c "SELECT FROM five_day_growth()" > /dev/null

}

load-data daily
