https://aws.amazon.com/blogs/database/managing-postgresql-users-and-roles/#:~:text=Users%2C%20groups%2C%20and%20roles%20are,to%20log%20in%20by%20default.&text=The%20roles%20are%20used%20only,grant%20them%20all%20the%20permissions.

CREATE ROLE aru_app_user NOSUPERUSER NOCREATEDB NOCREATEROLE NOINHERIT LOGIN PASSWORD 'aru!@#123';

GRANT CONNECT ON DATABASE postgres TO aru_app_user;
GRANT USAGE ON SCHEMA ecom TO aru_app_user;
GRANT SELECT ON ALL TABLES IN SCHEMA ecom TO aru_app_user;

ALTER DEFAULT PRIVILEGES IN SCHEMA ecom
GRANT ALL ON TABLES TO aru_app_user;

GRANT ALL ON TABLE tpl.addresses TO aru_app_user;

ALTER DEFAULT PRIVILEGES
FOR USER aru_app_user
IN SCHEMA ecom
GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO aru_app_user;

GRANT EXECUTE ON FUNCTION ecom.my_function() TO aru_app_user;

SELECT 
      r.rolname, 
      ARRAY(SELECT b.rolname
            FROM pg_catalog.pg_auth_members m
            JOIN pg_catalog.pg_roles b ON (m.roleid = b.oid)
            WHERE m.member = r.oid) as memberof
FROM pg_catalog.pg_roles r
WHERE r.rolname NOT IN ('pg_signal_backend','rds_iam',
                        'rds_replication','rds_superuser',
                        'rdsadmin','rdsrepladmin')
ORDER BY 1;


select * from pg_catalog.pg_roles;

CREATE ROLE readonly;
GRANT CONNECT ON DATABASE postgres TO readonly;
GRANT SELECT ON ALL TABLES IN SCHEMA ecom TO readonly;
ALTER DEFAULT PRIVILEGES IN SCHEMA ecom GRANT SELECT ON TABLES TO readonly;


CREATE ROLE readwrite;
GRANT CONNECT ON DATABASE postgres TO readwrite;
-- create privelege will allow user to create objetcs in the schema
GRANT USAGE, CREATE ON SCHEMA ecom TO readwrite; 
GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA ecom TO readwrite;
ALTER DEFAULT PRIVILEGES IN SCHEMA ecom GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO readwrite;
GRANT USAGE ON ALL SEQUENCES IN SCHEMA ecom TO readwrite;	
ALTER DEFAULT PRIVILEGES IN SCHEMA ecom GRANT USAGE ON SEQUENCES TO readwrite;

GRANT readwrite TO db_user_aru;

CREATE USER db_user_aru WITH PASSWORD 'aru@123';
CREATE ROLE arumugam SUPERUSER CREATEDB CREATEROLE INHERIT LOGIN PASSWORD 'aru!@#123';

CREATE ROLE test;
GRANT CONNECT ON DATABASE postgres TO test;
CREATE USER test WITH PASSWORD 'test@123';
alter user test with password 'test@123';
GRANT test TO test;

DROP role test;

revoke connect on database postgres from test;

select ((40-35)/40::numeric)*100::numeric