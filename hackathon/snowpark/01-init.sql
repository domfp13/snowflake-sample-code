USE ROLE USERADMIN;

-- Create a user
CREATE OR REPLACE USER snowpark_user
  PASSWORD = ''
  LOGIN_NAME = 'snowpark_user'
  DISPLAY_NAME = 'Snowpark User'
  FIRST_NAME = 'Snowpark'
  LAST_NAME = 'User'
  MUST_CHANGE_PASSWORD = FALSE
  DISABLED = FALSE
  DEFAULT_WAREHOUSE = HACKATHON_VW
  DEFAULT_NAMESPACE = HACKATHON
  DEFAULT_ROLE = SYSADMIN
  COMMENT = 'ENRIQUE PLATA SNOWPARK USER';

-- Grant privileges to the user
USE ROLE SECURITYADMIN;
GRANT ROLE SYSADMIN TO USER snowpark_user;

-- Create a database
USE ROLE SYSADMIN;
USE DATABASE HACKATHON;

CREATE OR REPLACE STAGE PUBLIC.XLS_LAKE DIRECTORY = (ENABLE = TRUE);

-- Create table to store the data from the XLS file (stage)
CREATE OR REPLACE TABLE PUBLIC.XLS_TABLE_STAGE
(
    "order_date"      VARCHAR,
    "allocation_date" VARCHAR,
    "so_number"       VARCHAR,
    "so_line"         VARCHAR,
    "cust_po"         VARCHAR,
    "end_user_po"     VARCHAR,
    "account_rep"     VARCHAR,
    "p_line"          VARCHAR,
    "td_pn"           VARCHAR,
    "manuf_pn"        VARCHAR
);

-- Create a final table to store the data from the XLS file from stage
CREATE OR REPLACE TABLE PUBLIC.XLS_TABLE
(
    order_date      DATE,
    allocation_date DATE,
    so_number       VARCHAR,
    so_line         VARCHAR,
    cust_po         VARCHAR,
    end_user_po     VARCHAR,
    account_rep     VARCHAR,
    p_line          VARCHAR,
    td_pn           VARCHAR,
    manuf_pn        VARCHAR
);

-- Create a stream to track changes in the stage
CREATE OR REPLACE STREAM PUBLIC.XLS_TABLE_STAGE_STREAM ON TABLE PUBLIC.XLS_TABLE_STAGE APPEND_ONLY = TRUE;

