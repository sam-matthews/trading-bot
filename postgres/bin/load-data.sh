#!/bin/zsh

# load-data.sh
# 3rd May 2020
# Sam Matthews

# Parameters
APP_HOME="${HOME}/dev/trading-bot"
POST_HOME="${APP_HOME}/postgres"
POST_SQL="${POST_HOME}/sql"

DAT_HOME="${HOME}/dev/alphavantage/dat"
WEEKLY_DAT="${DAT_HOME}/weekly"
DB_NAME="trading-bot"

# Truncate stock_daily and stock_weekly
psql -d ${DB_NAME} -t -c "TRUNCATE TABLE stock_daily"
psql -d ${DB_NAME} -t -c "TRUNCATE TABLE stock_weekly"

# Start of the LOOP


for STOCK in `ls -1 ${WEEKLY_DAT}`
do
  # echo the Stock name. Trim the extention off.
  T_STOCK="${STOCK%%.*}"

  echo "Loading data for ${T_STOCK}"

  # Truncate s_stock
  psql -d ${DB_NAME} -t -c "TRUNCATE TABLE s_stock"

  # Load stock into s_stock.
  psql -d ${DB_NAME} -t -c "\COPY s_stock FROM ${WEEKLY_DAT}/${STOCK} DELIMITER ',' CSV HEADER"

  # Load stock data into Atomic data with Stock Name.
  psql -d ${DB_NAME} -t -c \
  "INSERT INTO stock_weekly SELECT '${T_STOCK}', s_date, s_open, s_high, s_low, s_close, s_vol FROM s_stock"

done

# Generate list of stocks where they had a green candle in the last week.
echo "Generating list of Stocks which have Green Candles"
psql -d ${DB_NAME} -f $POST_SQL/green-candles.sql


# Load all CSV files into Staging table and then into Atomic table.
# Add Database name, which I get from the filename.
#

# Script will do the following for each stock.
# 1. Truncate s_stock table.
# 2. Insert data into staging data.
# 3. Load data into atomic table.

# Base Command to load data.
# psql -d trading-bot -t -c "\COPY s_stock FROM ./../alphavantage/dat/AAPL.csv DELIMITER ',' CSV HEADER"

# BASE command to Load data into atomic table.
# sql -d trading-bot -t -c "INSERT INTO stock_daily SELECT 'AAPL', * FROM s_stock"

# LOOP
#
