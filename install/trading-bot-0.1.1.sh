#!/bin/bash

# trading-bot-0.1.1.sh
# Sam Matthews
# 10th May 2020

# Install script for 0.1.1
# drop SMA staging tables.
# remove create table scripts for SMA staging tables.

# Related to alphavantage 1.0.4.

# remove staging tables.

psql -d trading-bot -c "DROP TABLE s_sma";
