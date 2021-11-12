https://carto.com/help/working-with-data/sql-stored-procedures/  
  
  RAISE INFO 'information message %', now() ;
  RAISE LOG 'log message %', now();
  RAISE DEBUG 'debug message %', now();
  RAISE WARNING 'warning message %', now();
  RAISE NOTICE 'notice message %', now();
**********************************************************************************************************************
DO $$DECLARE r record;
BEGIN
    FOR r IN SELECT table_schema, table_name FROM information_schema.tables
             WHERE table_type = 'VIEW' AND table_schema = 'public'
    LOOP
        EXECUTE 'GRANT ALL ON ' || quote_ident(r.table_schema) || '.' || quote_ident(r.table_name) || ' TO webuser';
    END LOOP;
END$$;


DO $$DECLARE r record;
BEGIN
    FOR r IN SELECT c.table_name , c.column_name  FROM information_schema."columns" c 
             WHERE column_name = 'sort_order' AND table_schema = 'ecom' and data_type ='bigint'
    LOOP
        EXECUTE 'Alter table ecom.' || quote_ident(r.table_name) || ' alter column sort_order TYPE int4 using sort_order::int4';
    END LOOP;
END$$;

**********************************************************************************************************************
create or replace function ecom.GetRows(text) returns setof record as
'
declare
r record;
begin
for r in EXECUTE ''select * from '' || $1 loop
return next r;
end loop;
return;
end
'
/*
 * select * from ecom.getrows( '(select created_date from ecom.product 
 * where created_date >= to_timestamp(''2021-07-06 17:00:00'',''yyyy-mm-dd hh24:mi:ss'')) a') as prd(created_date timestamp);
 */
language 'plpgsql';

**********************************************************************************************************************
create type returntype as
(
a int,
b int,
c_type1 varchar,
c_type2 varchar,
d_type1 varchar
d_type2 varchar
);

create function tst_func() returns setof returntype as
'
declare
r returntype%rowtype;
rLoopA RECORD;
rLoopB RECORD;
begin

for rLoopA IN
select a, b from foo where argle
loop

r.a := rLoopA.a;
r.b := rLoopA.b;

for rLoopB IN
select distinct on (foo, bar) foo, bar, data from sometable where bargle
-- this select may return a row for for every column of returntype
-- if a row/column is not returned, it should show null in the result set
loop

if foo = type1 and bar = c then
r.c_type1 := rLoopB;
else
r.c_type1 := NULL; -- note the explicit set to null
end if;

if foo = type2 and bar = c then
r.c_type2 := rLoopB;
else
r.c_type2 := NULL;
end if;

if foo = type1 and bar = d then
r.d_type1 := rLoopB;
else
r.d_type1 := NULL;
end if;

if foo = type2 and bar = d then
r.d_type2 := rLoopB;
else
r.d_type2 := NULL;
end if;

end loop;

return next r;

end loop;


end;
' language 'plpgsql';


**********************************************************************************************************************
if you are dealing with a WHERE clause in the EXECUTE SELECT, you may want to quote_literal() your string variables (if they are being passed in). For example:
CREATE FUNCTION public.sp_get_baz_for_cust(bpchar) RETURNS SETOF bpchar AS '
DECLARE cust_id ALIAS FOR $1;
baz_num CHAR( 15 );
selected_baz RECORD;

BEGIN

FOR selected_baz IN EXECUTE ''SELECT baz_number FROM baz_table WHERE customer_id = '' || quote_literal( cust_id ) LOOP
RETURN NEXT selected_baz.ticket_number;
END LOOP;

RETURN;

END;

**********************************************************************************************************************
select date_trunc('YEAR', current_date) + interval ; 

WITH RECURSIVE fib AS (
      SELECT 1 AS n
   UNION ALL
      SELECT n+1
      FROM fib
)
SELECT n FROM fib
LIMIT 12;

**********************************************************************************************************************


**********************************************************************************************************************