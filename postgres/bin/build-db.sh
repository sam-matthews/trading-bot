#!/bin/bash

# build-db.sh
# Sam Matthews
# 3rd May 2020

# Build database components from scratch. The idea is that it is rerunnable. Including it's components.
# Scripts should be rerunnable, although database will probably be dropped.

# Parameters

APP_HOME="$HOME/dev/trading-bot"
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
psql -d ${DBNAME} -f ${TAB}/cre-s_stock.sql
psql -d ${DBNAME} -f ${TAB}/cre-stock.sql
psql -d ${DBNAME} -f ${TAB}/cre-week-time-series.sql

