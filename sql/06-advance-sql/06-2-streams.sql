USE ROLE SYSADMIN;
USE WAREHOUSE SNOWPROCORE;
USE DATABASE SNOWPROCORE;
USE SCHEMA SNOWPROCORE.PUBLIC;

-- Create a stream to track changes to the ACCOUNTS_SCHEMA_EVOLUTION table
CREATE OR REPLACE STREAM SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION_STREAM ON TABLE SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION
 APPEND_ONLY = TRUE
 SHOW_INITIAL_ROWS = TRUE
 COMMENT = 'Stream to track changes to the ACCOUNTS_SCHEMA_EVOLUTION table';

-- Selecting from STREAMS to verify the stream was created
SELECT * FROM SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION_STREAM;

SELECT COUNT(*) FROM SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION;
SELECT COUNT(*) FROM SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION_STREAM;

-- Creating a table that will hold a subset of the information, this will demonstrate how to use the stream to populate a table.
CREATE OR REPLACE TABLE SNOWPROCORE.PUBLIC.ACCOUNTS_SILVER (
	ACCESSIBLE_BALANCE NUMBER(8,2),
	ACCOUNT_BALANCE NUMBER(8,2),
	ACCOUNT_STATUS_CODE NUMBER(1,0),
	ACCOUNT_UID VARCHAR(16777216),
	CDIC_HOLD_STATUS_CODE NUMBER(1,0),
	CURRENCY_CODE NUMBER(1,0)
);

SELECT * FROM SNOWPROCORE.PUBLIC.ACCOUNTS_SILVER;

-- Using the stream to populate the table
BEGIN;
	INSERT INTO SNOWPROCORE.PUBLIC.ACCOUNTS_SILVER
	SELECT ACCESSIBLE_BALANCE, ACCOUNT_BALANCE, ACCOUNT_STATUS_CODE, ACCOUNT_UID, CDIC_HOLD_STATUS_CODE, CURRENCY_CODE 
	FROM SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION_STREAM;
COMMIT;

SELECT * FROM SNOWPROCORE.PUBLIC.ACCOUNTS_SILVER;
SELECT * FROM SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION_STREAM;

-- ********* Lets load a new file to the original SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION table and see if the stream picks it up *********
-- NOTICE: THE FILE SNOWBANK_PUBLIC_ACCOUNTS_3.json has been changed in structure.
PUT file://///Users/eplata/Developer/personal/snowflake-sample-code/sql/06-advance-sql/SNOWBANK_PUBLIC_ACCOUNTS_3.json @SNOWPROCORE.PUBLIC.JSON_FILES_STAGE;

LIST @SNOWPROCORE.PUBLIC.JSON_FILES_STAGE;

-- COPY INTO SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION
COPY INTO SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION
  FROM @SNOWPROCORE.PUBLIC.JSON_FILES_STAGE
  FILE_FORMAT = SNOWPROCORE.PUBLIC.FILE_FORMAT_JSON_GENERIC
  MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
  PATTERN = '.*.json.gz'
  PURGE = TRUE;

-- Did the stream pick up the new file?
SELECT * FROM SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION_STREAM;

-- Can I use it to load the SNOWPROCORE.PUBLIC.ACCOUNTS_SILVER table?
BEGIN;
	INSERT INTO SNOWPROCORE.PUBLIC.ACCOUNTS_SILVER
	SELECT ACCESSIBLE_BALANCE, ACCOUNT_BALANCE, ACCOUNT_STATUS_CODE, ACCOUNT_UID, CDIC_HOLD_STATUS_CODE, CURRENCY_CODE 
	FROM SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION_STREAM;
COMMIT;

SELECT COUNT(*) FROM SNOWPROCORE.PUBLIC.ACCOUNTS_SILVER;
