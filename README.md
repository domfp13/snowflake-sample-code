# About
Generic all purpose repository with Snowflake sample code

# Setup
Add your credentials to the ./notebooks/credentials.py

# If you are using Codespaces or Devcontianers
Creating new python environment in dev container
```
conda create --name snowpark --override-channels -c https://repo.anaconda.com/pkgs/snowflake python=3.10 numpy pandas snowflake-snowpark-python
```

Installing xlrd python package which is used to read xls files
```
 conda install ipykernel
 conda install xlrd=2.0.1
```
