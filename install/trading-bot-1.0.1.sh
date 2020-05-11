#/bin/bash
# trading-bot-1.0.1.sh
# Sam Matthews
# 11th May 2020.

# Install script for 1.0.1. This release will essentially streamline tables and functions when loading
# - daily
# - weekly
# data. The idea been we reduce the number of tables and functions required to load daily and weekly tables.
# This is a good opportunity to change the way these tables are managed and standards for table and function naming.

DBNAME="trading-bot"

psql -d ${DBNAME} -c "DROP TABLE a_sma_daily_6"
psql -d ${DBNAME} -c "DROP TABLE a_sma_daily_12"
psql -d ${DBNAME} -c "DROP TABLE a_sma_stocks_to_buy"
psql -d ${DBNAME} -c "DROP TABLE a_sma_weekly_12"
psql -d ${DBNAME} -c "DROP TABLE a_sma_weekly_6"

