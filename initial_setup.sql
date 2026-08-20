-------------------------------------------------------
--SCRIPT PARA INICIAR EL SETUP DEL ENTORNO
-------------------------------------------------------

use role accountadmin;

-- creacion del role
create role if not exists dbt_role;

-- creacion del warehouse
create warehouse dbt_wh with warehouse_size='x-small';

-- creacion de la base de datos
create database if not exists propelling_tech_db;

-- asignar permisos
grant usage on warehouse dbt_wh to role dbt_role;
grant usage on schema public to role dbt_role;
grant role dbt_role to user carlotavila;
grant all on database propelling_tech_db to role dbt_role;
grant create schema on database propelling_tech_db to role dbt_role;

-- asignar el rol a mi ususario
grant role dbt_role to user carlotavila;

use role dbt_role;
use warehouse dbt_wh;
use database propelling_tech_db;


show integrations;