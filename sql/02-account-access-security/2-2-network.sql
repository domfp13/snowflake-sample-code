-- Example of creating a network policy

-- *******************1.- CREATE A USER NETWORK POLICY *******************
-- 1.- Creating a network policy for specific user (ADMIN)
USE ROLE SECURITYADMIN;

CREATE NETWORK POLICY ALLOW_PUBLIC_ACCESS_POLICY
  ALLOWED_IP_LIST = ('0.0.0.0/0')
  COMMENT = 'Allow public access to the account';

DESCRIBE NETWORK POLICY ALLOW_PUBLIC_ACCESS_POLICY;

SHOW NETWORK POLICIES;

USE ROLE ACCOUNTADMIN;

ALTER USER ENRIQUEP SET NETWORK_POLICY = ALLOW_PUBLIC_ACCESS_POLICY;

SHOW PARAMETERS LIKE 'NETWORK_POLICY' IN USER ENRIQUEP;

-- *******************2.- CREATE NEW NETWORK POLICY *******************
-- 2.1  Create a new user in the account
USE ROLE USERADMIN;

CREATE OR REPLACE USER NETWORK_TEST 
 PASSWORD = 'test_password' 
 DEFAULT_WAREHOUSE = 'SNOWPROCORE' 
 DEFAULT_ROLE = 'PUBLIC';

USE ROLE SECURITYADMIN;

GRANT ROLE PUBLIC TO USER NETWORK_TEST;

-- 2.2  Create new NETWORK POLICY FOR THE ACCOUNT
USE ROLE SECURITYADMIN;

CREATE NETWORK POLICY ALLOW_ACCESS_LOCAL_NETWORK_POLICY
  ALLOWED_IP_LIST = ('<YOUR_IP>')
  COMMENT = 'Allow access form the account';

ALTER ACCOUNT SET NETWORK_POLICY = ALLOW_ACCESS_LOCAL_NETWORK_POLICY;
