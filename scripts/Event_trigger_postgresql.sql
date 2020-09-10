--https://www.postgresql.org/docs/9.4/plpgsql-trigger.html
--https://www.tutorialdba.com/2017/09/how-to-create-postgresql-plpgsql.html

--DROP EVENT TRIGGER IF EXISTS snitch;

CREATE OR REPLACE FUNCTION snitch() RETURNS event_trigger AS $$
BEGIN
    RAISE NOTICE 'snitch: % %', tg_event, tg_tag;
END;
$$ LANGUAGE plpgsql;

CREATE EVENT TRIGGER snitch ON ddl_command_start EXECUTE PROCEDURE snitch();
