USE ROLE SYSADMIN;
USE WAREHOUSE SNOWPROCORE;
USE DATABASE SNOWPROCORE;

-- CREATE SCHEMA
CREATE OR REPLACE SCHEMA SNOWPROCORE.RAW COMMENT = 'Loading Schema'
    DATA_RETENTION_TIME_IN_DAYS = 2;

USE SCHEMA SNOWPROCORE.RAW;

-- CREATE CSV FILE FORMAT: FILE FORMAT OBJECTS ARE USED TO DEFINE THE STRUCTURE OF FILES THAT ARE LOADED INTO OR UNLOADED FROM SNOWFLAKE TABLES
CREATE OR REPLACE FILE FORMAT SNOWPROCORE.RAW.CSV_UNLOADING_FORMAT
    TYPE = 'CSV'
    FIELD_DELIMITER = ','
    RECORD_DELIMITER = '\n'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    TRIM_SPACE = TRUE
    COMPRESSION = 'NONE';

CREATE OR REPLACE STAGE SNOWPROCORE.RAW.FILES_STAGE DIRECTORY = ( ENABLE =  TRUE );

-- UPLOAD A CSV
PUT file:///Users/eplata/Developer/personal/snowflake-sample-code/sql/03-loading/data_0_0_0.csv @SNOWPROCORE.RAW.FILES_STAGE/ AUTO_COMPRESS=FALSE;

-- CREATE TABLE
CREATE OR REPLACE TABLE SNOWPROCORE.RAW.ACCOUNTS_RAW
(
    ACCESSIBLE_BALANCE                         VARCHAR,
    ACCOUNT_BALANCE                            VARCHAR,
    ACCOUNT_STATUS_CODE                        VARCHAR,
    ACCOUNT_UID                                VARCHAR,
    CDIC_HOLD_STATUS_CODE                      VARCHAR,
    CURRENCY_CODE                              VARCHAR,
    CURRENT_CDIC_HOLD_AMOUNT                   VARCHAR,
    DEPOSITOR_ID                               VARCHAR,
    INSURANCE_DETERMINATION_CATEGORY_TYPE_CODE VARCHAR,
    PRODUCT_CODE                               VARCHAR,
    REGISTERED_ACCOUNT_FLAG                    VARCHAR,
    REGISTERED_PLAN_TYPE_CODE                  VARCHAR,
    FILE_NAME                                  VARCHAR,
    FILE_ROW_NUMBER                            VARCHAR
);

-- COPY INTO TABLE
COPY INTO SNOWPROCORE.RAW.ACCOUNTS_RAW
    FROM @SNOWPROCORE.RAW.FILES_STAGE
    FILE_FORMAT = (FORMAT_NAME = SNOWPROCORE.RAW.CSV_UNLOADING_FORMAT)
    ON_ERROR = 'CONTINUE'
    PURGE = FALSE;

-- SELECT FROM TABLE
SELECT * FROM SNOWPROCORE.RAW.ACCOUNTS_RAW;

-- What happends if we try to copy the same file again?
-- What is the PURGE option doing?

-- Cleanup
DROP SCHEMA IF EXISTS SNOWPROCORE.RAW;
