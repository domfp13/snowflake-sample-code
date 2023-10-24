# Retreive the connection secrets
export SNOWSQL_PWD="$( python ./bin/parse_connection_secrets.py password )"

#start snowsql session
snowsql --config .app_store/snowsql_config.ini -a $SNOWSQL_ACCOUNT -u $SNOWSQL_USER