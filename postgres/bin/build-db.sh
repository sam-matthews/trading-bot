#!/bin/bash

# build-db.sh
# Sam Matthews
# 3rd May 2020

# Build database components from scratch. The idea is that it is rerunnable. Including it's components.
# Scripts should be rerunnable, although database will probably be dropped.

# History

# SMM 0.1.1 20200510 Remove s_sma staging table from script.

# Parameters

APP_HOME="$HOME/dev/projects/trading-bot"
POS_HOME="${APP_HOME}/postgres"
CRE="${POS_HOME}/cre"
TAB="${POS_HOME}/tab"
FUN="${POS_HOME}/fun"
IDX="${POS_HOME}/idx"

DBNAME="trading-bot"

# Create DB
# Do not connect to app databsae because we are trying to drop the database.
echo "Creating Database."
psql -f ${CRE}/cre-db.sql

# Create Tables
echo "Creating Tables."
echo " - Staging tables."

psql -d ${DBNAME} -f ${TAB}/s_stock.tab
psql -d ${DBNAME} -f ${TAB}/s_prev_week.tab

echo " - Intermediate Tables."

psql -d ${DBNAME} -f ${TAB}/i_sma_6_12.tab
psql -d ${DBNAME} -f ${TAB}/i_sma_temp_1.tab
psql -d ${DBNAME} -f ${TAB}/i_sma_temp_2.tab
psql -d ${DBNAME} -f ${TAB}/a_sma_6.tab
psql -d ${DBNAME} -f ${TAB}/a_sma_12.tab

echo " - Atomic tables"

psql -d ${DBNAME} -f ${TAB}/stock_daily.tab
psql -d ${DBNAME} -f ${TAB}/stock_weekly.tab
psql -d ${DBNAME} -f ${TAB}/final_daily_sma.tab

echo " - Tables to be decomissioned."
psql -d ${DBNAME} -f ${TAB}/c_prev_week.tab
psql -d ${DBNAME} -f ${TAB}/c_green_candles.tab
psql -d ${DBNAME} -f ${TAB}/ts_week.tab

# Indexes
psql -d ${DBNAME} -f ${IDX}/trading-bot.idx

# Functions
psql -d ${DBNAME} -f ${FUN}/i_sma.fun
psql -d ${DBNAME} -f ${FUN}/a_sma.fun
psql -d ${DBNAME} -f ${FUN}/final_daily_sma.fun
