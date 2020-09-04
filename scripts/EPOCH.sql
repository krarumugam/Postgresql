https://www.epochconverter.com/

SELECT EXTRACT(EPOCH FROM NOW())::integer;


SHOW SERVER_VERSION;
SHOW TIMEZONE;
SELECT extract(EPOCH FROM now())::bigint;


SHOW TIMEZONE;
SELECT extract(EPOCH FROM to_date('02-02-2010 15:15:15','dd-mm-yyyy hh24:mi:ss'))::bigint;


select to_date(1598860436);


SELECT to_timestamp(1598874666);


C:\Program Files\PostgreSQL\12\bin>psql postgres postgres < D:\Work\SuperMarketModel\Code\dev\Database\test.sql
-- restore database
pg_restore -U postgres -d postgres D:\somefilename.tar


psql -u postgres postgres < D:filename.sql

