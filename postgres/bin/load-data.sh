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
      DAT_LOCATION=${DAILY_DAT}
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

    # Truncate s_stock
    psql -d ${DBNAME} -t -c "TRUNCATE TABLE ${STAGING_TABLE}" > /dev/null

    # Load stock into s_stock.
    psql -d ${DBNAME} -t -c "\COPY ${STAGING_TABLE} FROM ${DAT_LOCATION}/${STOCK} DELIMITER ',' CSV HEADER" > /dev/null

    # Load stock data into stock table.
    echo "Loading into stock_daily"
    psql -d ${DBNAME} -t -c "INSERT INTO ${ATOMIC_TABLE} SELECT '${T_STOCK}', s_date, s_open, s_high, s_low, s_close, s_vol FROM s_stock" > /dev/null

    # Calculate SMA data
    echo "Loading into a_sma_6 and a_sma_12 - generating SMA data."
    psql -d ${DBNAME} -tc "SELECT FROM a_sma()" -c "\q"

    # Load SMA data into intemediate table
    echo "Loading i_sma_6_12 - Combining OHLC and SMA data."
    psql -d ${DBNAME} -f ${POST_SQL}/load_sma.sql

    # Load SMA data using LAG function. So we can make some really good decisions.
    echo "Load into i_sma_temp_1 and i_sma_temp_2 - Aggregate last three days."
    psql -d ${DBNAME} -tc "SELECT FROM i_sma()" -c "\q"

    if [ ${DAT_TYPE} = "daily" ]; then
      # Load daily data into final tables to display final stocks to choose from.
      psql -d ${DBNAME} -tc "SELECT FROM final_daily_sma()" -c "\q"
    else
      psql -d ${DBNAME} -tc "SELECT FROM final_daily_sma()" -c "\q"
    fi

  done

}

load-data daily
