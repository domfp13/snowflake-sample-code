USE ROLE SYSADMIN;
USE DATABASE SNOWPROCORE;
USE WAREHOUSE SNOWPROCORE;

-- ********************************* TRANSIENT *********************************

-- Creating Transient schema, what is going to happend to the tables that are created in this schema?
CREATE OR REPLACE TRANSIENT SCHEMA SNOWPROCORE.TRANSIENT_SCHEMA
 WITH MANAGED ACCESS
 COMMENT = 'This is a transient schema';

USE SCHEMA SNOWPROCORE.TRANSIENT_SCHEMA;

-- Creating a table in the transient schema
CREATE OR REPLACE TABLE SNOWPROCORE.TRANSIENT_SCHEMA.USERS (
    row_id NUMBER(38,0) IDENTITY (1,1) NOT NULL,
    user_name VARCHAR(50) NOT NULL,
    insert_date DATE DEFAULT CURRENT_DATE() NOT NULL
);

ALTER TABLE IF EXISTS SNOWPROCORE.TRANSIENT_SCHEMA.USERS SET DATA_RETENTION_TIME_IN_DAYS = 3; -- This will throw an error, because the table is in a transient schema.

SHOW TABLES IN SCHEMA SNOWPROCORE.TRANSIENT_SCHEMA;

-- Since retention time is set to 1 we could take advantage of the time travel feature

INSERT INTO SNOWPROCORE.TRANSIENT_SCHEMA.USERS (user_name) VALUES ('Bart'),('Luis'),('Robert');

SELECT LAST_QUERY_ID();

-- Selecting from table
SELECT * FROM SNOWPROCORE.TRANSIENT_SCHEMA.USERS;

-- With time travel
SELECT * FROM SNOWPROCORE.TRANSIENT_SCHEMA.USERS BEFORE (STATEMENT => '');

-- Dropping table
DROP TABLE IF EXISTS SNOWPROCORE.TRANSIENT_SCHEMA.USERS;
SELECT * FROM SNOWPROCORE.TRANSIENT_SCHEMA.USERS;

-- Undropping table
UNDROP TABLE SNOWPROCORE.TRANSIENT_SCHEMA.USERS;
SELECT * FROM SNOWPROCORE.TRANSIENT_SCHEMA.USERS;

-- ********************************* TEMPORARY *********************************
USE ROLE SYSADMIN;
USE WAREHOUSE SNOWPROCORE;
USE DATABASE SNOWPROCORE;
USE SCHEMA SNOWPROCORE.TRANSIENT_SCHEMA;

-- Creating a temporary table with the same name as the transient table, what do you think is going to happen, will the data be overwritten?
CREATE OR REPLACE TEMPORARY TABLE SNOWPROCORE.TRANSIENT_SCHEMA.USERS (
    row_id NUMBER(38,0) IDENTITY (1,1) NOT NULL,
    user_name VARCHAR(50) NOT NULL,
    insert_date DATE DEFAULT CURRENT_DATE() NOT NULL
);

-- Showing the tables in the schema
SHOW TABLES IN SCHEMA SNOWPROCORE.TRANSIENT_SCHEMA;

INSERT INTO SNOWPROCORE.TRANSIENT_SCHEMA.USERS (user_name) VALUES ('Charly'),('Theresa'),('Sophia');

SELECT LAST_QUERY_ID();

-- time travel in tmp tables?
SELECT * FROM SNOWPROCORE.TRANSIENT_SCHEMA.USERS BEFORE (STATEMENT => '01b2e4aa-0202-7162-0002-8bea0002b14a');

-- DROP TABLE
DROP TABLE IF EXISTS SNOWPROCORE.TRANSIENT_SCHEMA.USERS;

UNDROP TABLE SNOWPROCORE.TRANSIENT_SCHEMA.USERS;

SELECT * FROM SNOWPROCORE.TRANSIENT_SCHEMA.USERS;

-- Important to note that temporary tables are not visible to other users, and they are dropped when the session ends or after 1 day, 
-- undropping is possible only when temporary table is not replacing a permant transient table.
CREATE OR REPLACE TEMPORARY TABLE SNOWPROCORE.TRANSIENT_SCHEMA.USERS_TWO (
    row_id NUMBER(38,0) IDENTITY (1,1) NOT NULL,
    user_name VARCHAR(50) NOT NULL,
    insert_date DATE DEFAULT CURRENT_DATE() NOT NULL
);

INSERT INTO SNOWPROCORE.TRANSIENT_SCHEMA.USERS_TWO (user_name) VALUES ('Charly'),('Theresa'),('Sophia');

DROP TABLE IF EXISTS SNOWPROCORE.TRANSIENT_SCHEMA.USERS_TWO;

SELECT * FROM SNOWPROCORE.TRANSIENT_SCHEMA.USERS_TWO;

UNDROP TABLE SNOWPROCORE.TRANSIENT_SCHEMA.USERS_TWO;
SELECT * FROM SNOWPROCORE.TRANSIENT_SCHEMA.USERS_TWO;
