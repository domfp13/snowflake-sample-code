USE ROLE SYSADMIN;
USE WAREHOUSE COMPUTE_WH;
USE DATABASE FOOBAR_DB;
USE SCHEMA FOOBAR_DB.PUBLIC;

-- Starting the compute pool
ALTER COMPUTE POOL IF EXISTS COMPUTE_POOL_FOOBAR RESUME;
SHOW COMPUTE POOLS;

-- Showing images
SHOW IMAGE REPOSITORIES IN SCHEMA;
SELECT TRY_PARSE_JSON(SYSTEM$REGISTRY_LIST_IMAGES('/FOOBAR_DB/PUBLIC/images')) AS PAYLOAD;

-- ** Before running the following commands be sure to upload the image to the repository and upload the specs file to the stage **
CREATE SERVICE DBT_SERVICE
	IN COMPUTE POOL COMPUTE_POOL_FOOBAR
	FROM @SPECS
	SPEC = 'dbt-spec.yaml'
	MIN_INSTANCES = 1
	MAX_INSTANCES = 1;

SHOW SERVICES IN SCHEMA;

-- Checking logs
USE ROLE SYSADMIN;
USE DATABASE FOOBAR_DB;
USE SCHEMA FOOBAR_DB.PUBLIC;
SHOW COMPUTE POOLS;
SELECT SYSTEM$GET_SERVICE_STATUS('DBT_SERVICE');
SELECT SYSTEM$GET_SERVICE_LOGS('FOOBAR_DB.PUBLIC.DBT_SERVICE', 0, 'dbt-runner', 100);
SELECT SYSTEM$GET_SERVICE_LOGS('FOOBAR_DB.PUBLIC.DBT_SERVICE', 0, 'dbt-docs', 100);

-- Loggint table
SELECT TIMESTAMP, RESOURCE_ATTRIBUTES, RECORD_ATTRIBUTES, VALUE
FROM LOG_TRACE_DB.PUBLIC.EVENT_TABLE
WHERE TIMESTAMP > DATEADD(HOUR, -1, CURRENT_TIMESTAMP())
 AND RESOURCE_ATTRIBUTES:"snow.executable.type" = 'SnowparkContainers'
 AND RESOURCE_ATTRIBUTES:"snow.executable.name" = 'DBT_SERVICE'
 ORDER BY TIMESTAMP DESC;

-- Showing public endpoints
SHOW ENDPOINTS IN SERVICE DBT_SERVICE;

-- Suspending service
USE ROLE SYSADMIN;
SHOW COMPUTE POOLS;
DROP SERVICE IF EXISTS DBT_SERVICE;
ALTER COMPUTE POOL IF EXISTS COMPUTE_POOL_FOOBAR SUSPEND;
