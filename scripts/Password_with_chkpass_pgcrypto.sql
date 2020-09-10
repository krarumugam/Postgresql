--https://www.postgresql.fastware.com/blog/further-protect-your-data-with-pgcrypto
--https://www.dbrnd.com/2016/03/postgresql-best-way-for-password-encryption-using-pgcryptos-cryptographic-functions/
--https://www.postgresql.org/docs/12/pgcrypto.html



CREATE EXTENSION chkpass;

create table test_ckhpass (pws chkpass);

insert into test_ckhpass values ('Arumugam');

select pws, raw(pws) from test_ckhpass;

select pws = 'Arumugam' tst_pass, pws = 'asdsa' tst_fail from test_ckhpass tc ;




CREATE EXTENSION pgcrypto;

select * from public.store_admin sa ;

select CRYPT('Arum', GEN_SALT('md5'));

UPDATE public.store_admin SET PWD = CRYPT('Arum', GEN_SALT('md5')) WHERE ADMIN_ID = 3;

select TRUE from public.store_admin sa where ADMIN_ID = 3 and  pwd = crypt('Arum', pwd);


SELECT ENCODE(HMAC('AruPass','mykey','md5'),'hex');
SELECT ENCODE(HMAC('AruPass','mykey','sha1'),'hex');
SELECT ENCODE(HMAC('AruPass','mykey','sha224'),'hex');
SELECT ENCODE(HMAC('AruPass','mykey','sha256'),'hex');
SELECT ENCODE(HMAC('AruPass','mykey','sha384'),'hex');
SELECT ENCODE(HMAC('AruPass','mykey','sha512'),'hex');

select CRYPT('AruPass', GEN_SALT('md5'));

select 'Arumugam'::chkpass;

SELECT ENCODE(DIGEST('AruPass','md5'),'hex'), ENCODE(HMAC('AruPass','mykey','md5'),'hex');
SELECT ENCODE(DIGEST('AruPass','sha1'),'hex');
SELECT ENCODE(DIGEST('AruPass','sha224'),'hex');
SELECT ENCODE(DIGEST('AruPass','sha256'),'hex');
SELECT ENCODE(DIGEST('AruPass','sha384'),'hex');
SELECT ENCODE(DIGEST('AruPass','sha512'),'hex');


SELECT DIGEST('AruPass','md5'), HMAC('AruPass','mykey','md5');

select CRYPT('Arum', GEN_SALT('md5'));

select * from public.store_admin sa ;


select pgp_sym_encrypt('test', 'psw text' ) ;

select pgp_sym_decrypt( (select pgp_sym_encrypt('test', 'psw text1' )), 'psw text1');

select armor('data text');  

select dearmor ( select armor('data text')::text );