-- Create a warehouse
USE ROLE SYSADMIN;
CREATE OR REPLACE WAREHOUSE EXTERNAL_ACCESS_WH
  WAREHOUSE_SIZE = 'XSMALL'
  WAREHOUSE_TYPE = 'STANDARD'
  AUTO_SUSPEND = 60
  AUTO_RESUME = TRUE
  MIN_CLUSTER_COUNT = 1
  MAX_CLUSTER_COUNT = 1
  SCALING_POLICY = 'ECONOMY';

-- Create a database
USE ROLE SYSADMIN;
CREATE OR REPLACE DATABASE EXTERNAL_ACCESS_DB;

-- Create user
USE ROLE USERADMIN;
CREATE OR REPLACE USER EXTERNAL_ACCESS_USER
  LOGIN_NAME = 'external_access_user'
  PASSWORD = 'Password1'
  MUST_CHANGE_PASSWORD = FALSE
  DEFAULT_ROLE = SYSADMIN
  DEFAULT_WAREHOUSE = EXTERNAL_ACCESS_WH
  DEFAULT_NAMESPACE = EXTERNAL_ACCESS_DB;

-- Grant privileges
USE ROLE SECURITYADMIN;
GRANT ROLE SYSADMIN TO USER EXTERNAL_ACCESS_USER;

-- External network rule
USE ROLE SYSADMIN;
USE DATABASE EXTERNAL_ACCESS_DB;
USE SCHEMA PUBLIC;

-- Create a network rule
CREATE OR REPLACE NETWORK RULE google_apis_network_rule
  MODE = EGRESS
  TYPE = HOST_PORT
  VALUE_LIST = ('translation.googleapis.com');

SHOW NETWORK RULES;

-- Create a security integration
USE ROLE ACCOUNTADMIN;
CREATE OR REPLACE SECURITY INTEGRATION google_translate_oauth
  TYPE = API_AUTHENTICATION
  AUTH_TYPE = OAUTH2
  OAUTH_CLIENT_ID = '<client_id>'
  OAUTH_CLIENT_SECRET = '<client_secret>'
  OAUTH_TOKEN_ENDPOINT = 'https://oauth2.googleapis.com/token'
  OAUTH_AUTHORIZATION_ENDPOINT = 'https://accounts.google.com/o/oauth2/auth'
  OAUTH_ALLOWED_SCOPES = ('https://www.googleapis.com/auth/cloud-platform')
  ENABLED = TRUE;

GRANT USAGE ON INTEGRATION google_translate_oauth TO ROLE SYSADMIN;

-- Creating a secret to hold the refresh token
USE ROLE SYSADMIN;

CREATE OR REPLACE SECRET oauth_token
  TYPE = oauth2
  API_AUTHENTICATION = google_translate_oauth
  OAUTH_REFRESH_TOKEN = '<refresh_token>';

-- Create an external access integration
USE ROLE SYSADMIN;
CREATE OR REPLACE EXTERNAL ACCESS INTEGRATION google_apis_access_integration
  ALLOWED_NETWORK_RULES = (google_apis_network_rule)
  ALLOWED_AUTHENTICATION_SECRETS = (oauth_token)
  ENABLED = true;

SHOW EXTERNAL ACCESS INTEGRATIONS;

-- Create a function
USE ROLE SYSADMIN;
CREATE OR REPLACE FUNCTION EXTERNAL_ACCESS_DB.PUBLIC.google_translate_python(sentence STRING, language STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = 3.8
HANDLER = 'get_translation'
EXTERNAL_ACCESS_INTEGRATIONS = (google_apis_access_integration)
PACKAGES = ('snowflake-snowpark-python','requests')
SECRETS = ('cred' = oauth_token )
AS
$$
import _snowflake
import requests
import json
session = requests.Session()
def get_translation(sentence, language):
  token = _snowflake.get_oauth_access_token('cred')
  url = "https://translation.googleapis.com/language/translate/v2"
  data = {'q': sentence,'target': language}
  response = session.post(url, json = data, headers = {"Authorization": "Bearer " + token})
  return response.json()['data']['translations'][0]['translatedText']
$$;

USE ROLE SYSADMIN;
USE WAREHOUSE EXTERNAL_ACCESS_WH;
SELECT EXTERNAL_ACCESS_DB.PUBLIC.google_translate_python('Good morning', 'es');

CREATE TABLE EXTERNAL_ACCESS_DB.PUBLIC.TRANSLATIONS
(
  SENTENCE VARCHAR(1000)
);

INSERT INTO EXTERNAL_ACCESS_DB.PUBLIC.TRANSLATIONS (SENTENCE) VALUES ('Keep in mind that these are general differences and both novels and films can vary widely in their storytelling techniques based on the preferences of the author/director and the specific genre or style of the work.')
INSERT INTO EXTERNAL_ACCESS_DB.PUBLIC.TRANSLATIONS (SENTENCE) VALUES ('The name of your OAuth 2.0 client. This name is only used to identify the client in the console and will not be shown to end users.');

SELECT SENTENCE FROM EXTERNAL_ACCESS_DB.PUBLIC.TRANSLATIONS;
SELECT SENTENCE, EXTERNAL_ACCESS_DB.PUBLIC.google_translate_python(SENTENCE, 'DE') FROM EXTERNAL_ACCESS_DB.PUBLIC.TRANSLATIONS;

USE ROLE SYSADMIN;
