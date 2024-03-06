USE ROLE SYSADMIN;
USE DATABASE SNOWPROCORE;
USE SCHEMA PUBLIC;

-- ****************************** 1.- Virtual Warehouse ******************************
-- A virtual warehouse is a cluster of compute resources in Snowflake. It is used to execute SQL queries and perform other data processing tasks.
CREATE OR REPLACE WAREHOUSE SNOWPROCORE WITH
    WAREHOUSE_SIZE = 'X-SMALL' -- { XSMALL | SMALL | MEDIUM | LARGE | XLARGE | XXLARGE | XXXLARGE | X4LARGE | X5LARGE | X6LARGE }
    MIN_CLUSTER_COUNT = 1
    MAX_CLUSTER_COUNT = 2
    SCALING_POLICY = ECONOMY -- { STANDARD | ECONOMY }
    AUTO_SUSPEND = 180
    AUTO_RESUME = TRUE
    INITIALLY_SUSPENDED = TRUE -- { TRUE | FALSE };
    MAX_CONCURRENCY_LEVEL = 4
    STATEMENT_QUEUED_TIMEOUT_IN_SECONDS = 600 -- DEFAULT VALUE = 0 
    STATEMENT_TIMEOUT_IN_SECONDS = 600 -- DEFAULT VALUE = 0
;

USE WAREHOUSE SNOWPROCORE;

-- ****************************** 2.- File Format and Stage ******************************
-- When you load data from a file into a table, you must describe the format of the file and specify how the data in the file should be interpreted and processed.
CREATE OR REPLACE FILE FORMAT SNOWPROCORE.PUBLIC.FILE_FORMAT_JSON_GENERIC
 TYPE = 'JSON'
 ENABLE_OCTAL = FALSE
 ALLOW_DUPLICATE  = TRUE
 STRIP_OUTER_ARRAY = TRUE
 STRIP_NULL_VALUES = TRUE
 IGNORE_UTF8_ERRORS = FALSE;

-- A stage is a location in Snowflake where data files are stored. You can use a stage to load data into tables, or to unload data from tables.
CREATE OR REPLACE STAGE SNOWPROCORE.PUBLIC.STAGE_INTERNAL_ACCOUNTS
    DIRECTORY = ( ENABLE =  TRUE );

-- Load data into a stage
PUT file:////Users/eplata/Developer/personal/snowflake-sample-code/sql/09-observability/*.json @SNOWPROCORE.PUBLIC.STAGE_INTERNAL_ACCOUNTS;

-- Snowflake allows you to query the contents of a stage using a SELECT statement. This is useful for previewing the contents of a stage before loading the data into a table.
SELECT * FROM @SNOWPROCORE.PUBLIC.STAGE_INTERNAL_ACCOUNTS (FILE_FORMAT => SNOWPROCORE.PUBLIC.FILE_FORMAT_JSON_GENERIC) SAMPLE(100 ROWS);

-- ****************************** 3.- Loading data Into a Table ******************************
CREATE OR REPLACE TABLE SNOWPROCORE.PUBLIC.ACCOUNTS_INTERNAL_RAW (
    PAYLOAD VARIANT,
    LOAD_DATE TIMESTAMP_LTZ(9) DEFAULT CURRENT_TIMESTAMP()
);

COPY INTO SNOWPROCORE.PUBLIC.ACCOUNTS_INTERNAL_RAW (PAYLOAD)
FROM (
    SELECT $1 AS PAYLOAD
    FROM @SNOWPROCORE.PUBLIC.STAGE_INTERNAL_ACCOUNTS (FILE_FORMAT => SNOWPROCORE.PUBLIC.FILE_FORMAT_JSON_GENERIC)
)
FILE_FORMAT = SNOWPROCORE.PUBLIC.FILE_FORMAT_JSON_GENERIC
PATTERN = '.*.json.gz'
--PATTERN = '.*.json'
ON_ERROR = 'skip_file'
PURGE = TRUE
;

-- ****************************** 4.- Querying the Table ******************************
SELECT * FROM SNOWPROCORE.PUBLIC.ACCOUNTS_INTERNAL_RAW;

LIST @SNOWPROCORE.PUBLIC.STAGE_INTERNAL_ACCOUNTS;

-- ****************************** 5.- Flattening the RAW Table ******************************
CREATE OR REPLACE TABLE SNOWPROCORE.PUBLIC.ACCOUNTS (
    ACCESSIBLE_BALANCE                         FLOAT,
    ACCOUNT_BALANCE                            FLOAT,
    ACCOUNT_STATUS_CODE                        INT,
    ACCOUNT_UID                                VARCHAR,
    CDIC_HOLD_STATUS_CODE                      INT,
    CURRENCY_CODE                              INT,
    CURRENT_CDIC_HOLD_AMOUNT                   FLOAT,
    DEPOSITOR_ID                               VARCHAR,
    INSURANCE_DETERMINATION_CATEGORY_TYPE_CODE INT,
    PRODUCT_CODE                               INT,
    REGISTERED_ACCOUNT_FLAG                    BOOLEAN,
    REGISTERED_PLAN_TYPE_CODE                  INT
);

INSERT INTO SNOWPROCORE.PUBLIC.ACCOUNTS
SELECT $1:ACCESSIBLE_BALANCE::FLOAT AS ACCESSIBLE_BALANCE,
       $1:ACCOUNT_BALANCE::FLOAT AS ACCOUNT_BALANCE,
       $1:ACCOUNT_STATUS_CODE::INT AS ACCOUNT_STATUS_CODE,
       $1:ACCOUNT_UID::VARCHAR AS ACCOUNT_UID,
       $1:CDIC_HOLD_STATUS_CODE::INT AS CDIC_HOLD_STATUS_CODE,
       $1:CURRENCY_CODE::INT AS CURRENCY_CODE,
       $1:CURRENT_CDIC_HOLD_AMOUNT::FLOAT AS CURRENT_CDIC_HOLD_AMOUNT,
       $1:DEPOSITOR_ID::VARCHAR AS DEPOSITOR_ID,
       $1:INSURANCE_DETERMINATION_CATEGORY_TYPE_CODE::INT AS INSURANCE_DETERMINATION_CATEGORY_TYPE_CODE,
       $1:PRODUCT_CODE::INT AS PRODUCT_CODE,
       $1:REGISTERED_ACCOUNT_FLAG::BOOLEAN AS REGISTERED_ACCOUNT_FLAG,
       $1:REGISTERED_PLAN_TYPE_CODE::INT AS REGISTERED_PLAN_TYPE_CODE
FROM SNOWPROCORE.PUBLIC.ACCOUNTS_INTERNAL_RAW;

SELECT * FROM SNOWPROCORE.PUBLIC.ACCOUNTS;
-- 
SHOW DATA METRIC FUNCTIONS;

CREATE OR REPLACE DATA METRIC FUNCTION SNOWPROCORE.PUBLIC.FOREIGN_KEY_PRODUCT_CODE (arg_t TABLE (arg_c INT))
RETURNS NUMBER AS
'SELECT COUNT(*) FROM arg_t
   WHERE arg_c IN (SELECT PRODUCT_CODE FROM SNOWPROCORE.PUBLIC.PRODUCT_CODE)';

SELECT SNOWPROCORE.PUBLIC.FOREIGN_KEY_PRODUCT_CODE (SELECT PRODUCT_CODE FROM SNOWPROCORE.PUBLIC.ACCOUNTS);

ALTER TABLE SNOWPROCORE.PUBLIC.ACCOUNTS
SET DATA_METRIC_SCHEDULE = ‘TRIGGER_ON_CHANGES’;




alter account <account-name> set ENABLE_DATA_QUALITY=TRUE,
                     parameter_comment='SNOW-802250 - Enable Data Metric Function in <deployment>.<account-name>' 
                     jira_reference='SNOW-802250'
;
