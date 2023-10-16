USE ROLE SYSADMIN;
-- Creating a virtual warehouse
CREATE OR REPLACE WAREHOUSE XSMALL 
	WITH WAREHOUSE_SIZE = 'XSMALL' 
		 WAREHOUSE_TYPE = 'STANDARD' 
		 AUTO_SUSPEND = 60 
		 AUTO_RESUME = TRUE 
		 MIN_CLUSTER_COUNT = 1 
		 MAX_CLUSTER_COUNT = 2 
		 SCALING_POLICY = 'ECONOMY' 
		 INITIALLY_SUSPENDED = TRUE;

-- Showing Snowflake SHARES
SHOW SHARES;

-- Get the name of the share and assign it to a variable
SELECT * FROM TABLE(RESULT_SCAN(LAST_QUERY_ID()));

SELECT name 

-- Creating a database in snowflake
CREATE OR REPLACE DATABASE PROVIDER_DB COMMENT = 'Provider Database' DATA_RETENTION_TIME_IN_DAYS = 1;

-- Creating sales table
CREATE OR REPLACE TABLE PROVIDER_DB.PUBLIC.SALES (
        id              number,
        country_id      varchar,
        sales_date      date, 
        sales_amount    number
);

-- Adding some records to the table sales
INSERT INTO PROVIDER_DB.PUBLIC.SALES (id, country_id, sales_date, sales_amount) VALUES
 (1,'DE','2021-09-01',10901),
 (2,'DE','2021-10-01',11001),
 (3,'NL','2021-09-01',20901),
 (4,'NL','2021-10-01',21001),
 (5,'US','2021-09-01',30901),
 (6,'US','2021-10-01',31001);

-- Selecting off the new table sales
SELECT * FROM PROVIDER_DB.PUBLIC.SALES;

-- Creating Policy mapping table
CREATE OR REPLACE TABLE PROVIDER_DB.PUBLIC.COUNTRY_POLICY_MAPPING (
    COUNTRY_ID      VARCHAR,
    ACCOUNT_NAME    VARCHAR
);

-- Inserting some records into the country_policy_mapping table
INSERT INTO PROVIDER_DB.PUBLIC.COUNTRY_POLICY_MAPPING(COUNTRY_ID, ACCOUNT_NAME) VALUES
  ('DE','ZR43731'),
  ('NL','ZR43731'),
  ('US','ZR43731'),
  ('US','LX44659');

-- Selecting off the new table country_policy_mapping
SELECT * FROM PROVIDER_DB.PUBLIC.COUNTRY_POLICY_MAPPING;

-- Creating a row access policy for the sales table
CREATE OR REPLACE ROW ACCESS POLICY PROVIDER_DB.PUBLIC.SIMPLE_POLICY AS (country_id VARCHAR) RETURNS BOOLEAN ->
  'ZR43731' = CURRENT_ACCOUNT()
      OR EXISTS (
            SELECT 1 FROM PROVIDER_DB.PUBLIC.COUNTRY_POLICY_MAPPING mpt
            WHERE ACCOUNT_NAME = CURRENT_ACCOUNT()
             AND mpt.country_id = country_id
          )
;

-- Adding the row access policy to the sales table
ALTER TABLE PROVIDER_DB.PUBLIC.SALES
  ADD ROW ACCESS POLICY PROVIDER_DB.PUBLIC.SIMPLE_POLICY ON (COUNTRY_ID);

-- Selecting off the table sales (should return 6 records for the provider)
SELECT * FROM PROVIDER_DB.PUBLIC.SALES;

-- Adding to a listing

-- Creating a secure function that works in the consumer side
CREATE OR REPLACE SECURE FUNCTION IPINFO.PUBLIC.GET_CURRENT_ROLE() RETURNS STRING
AS
$$
    SELECT role_name
    FROM TABLE(INFORMATION_SCHEMA.QUERY_HISTORY_BY_SESSION(RESULT_LIMIT=>1)) 
$$;

-- CREATING MASKING POLICY FOR COLUMN ID
CREATE OR REPLACE MASKING POLICY id_mask AS (VAL NUMERIC) RETURNS NUMERIC -> 
    CASE
    WHEN PUBLIC.GET_CURRENT_ROLE() IN ('SYSADMIN','ACCOUNTADMIN') THEN VAL
    ELSE 0
END;

-- Apply masking to the sales table
ALTER TABLE IF EXISTS IPINFO.PUBLIC.SALES MODIFY COLUMN id SET MASKING POLICY id_mask;

-- Remove column policy
-- ALTER TABLE IPINFO.PUBLIC.SALES ALTER COLUMN id UNSET MASKING POLICY;
-- DROP MASKING POLICY id_mask;
  
SELECT * FROM IPINFO.PUBLIC.SALES;




INSERT INTO IPINFO.PUBLIC.SALES (id, country_id, sales_date, sales_amount) VALUES 
 (7,'US','2021-09-01',500);

DELETE FROM IPINFO.PUBLIC.SALES WHERE ID = 7;