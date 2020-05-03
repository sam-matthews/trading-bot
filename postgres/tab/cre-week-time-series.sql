/*

    cre-week-time-series.sql
    3rd May 2020
    Sam Matthews

    Script will generate which days are on a Monday and what days are on a Friday. This will assist when generating when to start the week and when to finish the week.

    The idea will be to use this table in a join to determine data for start of week and end of week.

*/

--DROP TABLE IF EXISTS ts_week;
--CREATE TABLE IF NOT EXISTS ts_week

DROP TABLE IF EXISTS ts_week;
CREATE TABLE ts_week ( dd TIMESTAMP, dw INTEGER);

INSERT INTO ts_week
WITH days AS
(
    SELECT dd, EXTRACT(DOW FROM dd) dw
    FROM GENERATE_SERIES('1900-01-01'::DATE, '2050-12-31'::DATE, '1 day'::INTERVAL) dd
)
SELECT * FROM days WHERE dw IN (1,5);
