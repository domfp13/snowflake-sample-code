#!/bin/bash

# print out a message
echo "Starting dbt container"

# change directory to the transformations folder
cd /usr/src/app/transformations

# print current directory
pwd

# run dbt compile
echo "Compiling dbt project"
dbt compile
echo "Loading Seed Data"
dbt seed
echo "Compiling dbt project"
dbt run

# Keep the script running indefinitely (use for debugging or when task services is in public preview)
tail -f /dev/null
