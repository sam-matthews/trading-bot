#!/bin/bash

#
# drop-database.sh
# Sam Matthews
# Drop Postgres database and user, including tables.
#

DBNAME=trading-bot

echo "Create Postgres User"
sudo -u postgres createuser --createdb ${DBNAME}

ERR_STATUS=$?
if [[ ${ERR_STATUS} -ne 0 ]]; then
  echo "Error: $0: Error creating user."
  exit 10
fi

echo "Create Postgres Database"
sudo -u postgres createdb ${DBNAME}

ERR_STATUS=$?
if [[ ${ERR_STATUS} -ne 0 ]]; then
  echo "Error: $0: Error creating database."
  exit 10
fi
