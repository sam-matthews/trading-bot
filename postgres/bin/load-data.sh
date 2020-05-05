#!/bin/zsh

# load-data.sh
# 3rd May 2020
# Sam Matthews

# Parameters
APP_HOME="${HOME}/dev/projects/trading-bot"
POST_HOME="${APP_HOME}/postgres"
POST_SQL="${POST_HOME}/sql"
POST_BIN="${POST_HOME}/bin"

DAT_HOME="${HOME}/dev/projects/USStocks/dat"
WEEKLY_DAT="${DAT_HOME}/weekly"
WEEKLY_SMA6_DAT="${DAT_HOME}/weekly-sma-6"
WEEKLY_SMA12_DAT="${DAT_HOME}/weekly-sma-12"
DAILY_DAT="${DAT_HOME}/daily"
DAILY_SMA6_DAT="${DAT_HOME}/SMA6"
DAILY_SMA12_DAT="${DAT_HOME}/SMA12"

DBNAME="trading-bot"

# Start of the LOOP

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
      ATOMIC_TABLE="stock_weekly"
      ;;

    *)
      echo "ERROR: Type needs to be DAILY or WEEKLY"
      exit 10
      ;;

  esac

  STAGING_TABLE="s_stock"
  # TRUNCATE ATOMIC TABLE because we will do a FULL LOAD.
  psql -d ${DBNAME} -t -c "TRUNCATE TABLE ${ATOMIC_TABLE}" > /dev/null

  for STOCK in `ls -1 ${DAT_LOCATION}`
  do

    # echo the Stock name. Trim the extention off.
    T_STOCK="${STOCK%%.*}"

    # Truncate s_stock
    psql -d ${DBNAME} -t -c "TRUNCATE TABLE ${STAGING_TABLE}" > /dev/null

    # Load stock into s_stock.
    psql -d ${DBNAME} -t -c "\COPY ${STAGING_TABLE} FROM ${DAT_LOCATION}/${STOCK} DELIMITER ',' CSV HEADER" > /dev/null

    # Load stock data into Atomic data with Stock Name.
    psql -d ${DBNAME} -t -c "INSERT INTO ${ATOMIC_TABLE} SELECT '${T_STOCK}', s_date, s_open, s_high, s_low, s_close, s_vol FROM s_stock" > /dev/null

  done

}

load-data-sma() {

  DAT_TYPE=$1

  echo "Choosing to run in ${DAT_TYPE} mode."

  case ${DAT_TYPE} in

    daily_sma6)
      DAT_LOCATION=${DAILY_SMA6_DAT}
      ATOMIC_TABLE="a_sma_daily_6"
      ;;

    daily_sma12)
      DAT_LOCATION=${DAILY_SMA12_DAT}
      ATOMIC_TABLE="a_sma_daily_12"
      ;;

    *)
      echo "ERROR: Type needs to be SMA related."
      exit 10
      ;;

  esac

  STAGING_TABLE="s_sma"
  # TRUNCATE ATOMIC TABLE because we will do a FULL LOAD.
  psql -d ${DBNAME} -t -c "TRUNCATE TABLE ${ATOMIC_TABLE}"

  for STOCK in `ls -1 ${DAT_LOCATION}`
  do

    # echo the Stock name. Trim the extention off.
    T_STOCK="${STOCK%%.*}"

    echo "Processing ${T_STOCK}"
    # Truncate s_stock
    psql -d ${DBNAME} -t -c "TRUNCATE TABLE ${STAGING_TABLE}" > /dev/null

    # Load stock into s_stock.
    psql -d ${DBNAME} -t -c "\COPY ${STAGING_TABLE} FROM ${DAT_LOCATION}/${STOCK} DELIMITER ',' CSV HEADER" > /dev/null

    # Load stock data into Atomic data with Stock Name.
    psql -d ${DBNAME} -t -c "INSERT INTO ${ATOMIC_TABLE} SELECT '${T_STOCK}', s_date, s_sma FROM s_sma" > /dev/null

  done

}

load-data daily
load-data-sma daily_sma6
load-data-sma daily_sma12

# Load data into intermediate table.
psql -d ${DBNAME} -f ${POST_SQL}/load_sma.sql

