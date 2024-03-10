-- Creating a task that orchestrates the entire process
USE ROLE SYSADMIN;
USE WAREHOUSE SNOWPROCORE;
USE DATABASE SNOWPROCORE;
USE SCHEMA SNOWPROCORE.PUBLIC;

-- Creating a Task that will kick off the process
CREATE OR REPLACE TASK SNOWPROCORE.PUBLIC.LOAD_JSON_FILES_TASK
  SCHEDULE = '5 MINUTE'
  ALLOW_OVERLAPPING_EXECUTION = FALSE
  SUSPEND_TASK_AFTER_NUM_FAILURES = 3
  COMMENT = 'Task to load JSON files from the stage into the target table'
  AS
	COPY INTO SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION
	FROM @SNOWPROCORE.PUBLIC.JSON_FILES_STAGE
	FILE_FORMAT = SNOWPROCORE.PUBLIC.FILE_FORMAT_JSON_GENERIC
	MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
	PATTERN = '.*.json.gz'
	PURGE = TRUE;
-- Why do we get an error when we try to create the task?

-- Enabling the Task
USE ROLE ACCOUNTADMIN;
GRANT EXECUTE MANAGED TASK ON ACCOUNT TO ROLE SYSADMIN;
GRANT EXECUTE TASK ON ACCOUNT TO ROLE SYSADMIN;

-- Let's try to create the task again
USE ROLE SYSADMIN;
USE WAREHOUSE SNOWPROCORE;
USE DATABASE SNOWPROCORE;
USE SCHEMA SNOWPROCORE.PUBLIC;

CREATE OR REPLACE TASK SNOWPROCORE.PUBLIC.LOAD_JSON_FILES_TASK
  SCHEDULE = '5 MINUTE'
  ALLOW_OVERLAPPING_EXECUTION = FALSE
  SUSPEND_TASK_AFTER_NUM_FAILURES = 3
  COMMENT = 'Task to load JSON files from the stage into the target table'
  AS
	COPY INTO SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION
	FROM @SNOWPROCORE.PUBLIC.JSON_FILES_STAGE
	FILE_FORMAT = SNOWPROCORE.PUBLIC.FILE_FORMAT_JSON_GENERIC
	MATCH_BY_COLUMN_NAME = CASE_INSENSITIVE
	PATTERN = '.*.json.gz'
	PURGE = TRUE;


-- EXECUTING THE TASK
ALTER TASK IF EXISTS SNOWPROCORE.PUBLIC.LOAD_JSON_FILES_TASK RESUME; -- BY DEFAULT THE TASK ARE SUSPENDED WHEN CREATED
EXECUTE TASK SNOWPROCORE.PUBLIC.LOAD_JSON_FILES_TASK;

-- CHECKING THE TASK
SHOW TASKS IN SNOWPROCORE.PUBLIC;
LIST @SNOWPROCORE.PUBLIC.JSON_FILES_STAGE;

-- CHECK THE TARGET TABLE
SELECT COUNT(*) FROM SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION;

-- CHECK THE STREAM 
SELECT * FROM SNOWPROCORE.PUBLIC.ACCOUNTS_SCHEMA_EVOLUTION_STREAM;

-- HOMEWORK CREATE TASK THAT LOADS THE DATA FROM THE STREAM INTO THE FINAL TABLE "SNOWPROCORE.PUBLIC.ACCOUNTS_SILVER"

-- ************** CLEAN UP **************
USE ROLE ACCOUNTADMIN;
DROP TASK IF EXISTS SNOWPROCORE.PUBLIC.LOAD_JSON_FILES_TASK;
REVOKE EXECUTE MANAGED TASK ON ACCOUNT FROM ROLE SYSADMIN; 
REVOKE EXECUTE TASK ON ACCOUNT FROM ROLE SYSADMIN;
