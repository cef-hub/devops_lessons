create user prod with password 'prod' createdb;
create database prod
 with owner prod
 encoding = 'utf8'
 LC_COLLATE = 'en_US.utf8'
 lc_ctype = 'en_US.utf8'
 tablespace = pg_default
 connection limit = -1;
