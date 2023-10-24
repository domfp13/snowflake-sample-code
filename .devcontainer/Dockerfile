# This is the base image, which has miniconda installed.
# You could use the 'anaconda' base image too; however the docker image 
# size will be large feel free to change it to your needs.
#
# There are 2 versions of the FROM statement.
# - The '--platform=linux/amd64' allows us to work locally, If you have a ARM-based system (e.g. Apple M1 M2...).
#       However, this version has issues when running a streamlit app either in the
#       local(docker) environment and also in a Github Codespace.
#
# - The one without the 'platform' allows you to run streamlit in a Github Codespace,
#       However, this means that streamlit app cannot be developed via the local(docker)
#       environment. 

# This is the base image
#FROM --platform=linux/amd64 continuumio/miniconda3 AS base
FROM continuumio/miniconda3 AS base
LABEL maintainer="Enrique Plata"
ENV APP_HOME /opt/notebooks
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Update container OS and pip
FROM base AS installer
USER root
RUN apt-get update && \
    apt-get install -y curl unzip && \
    echo "running in codespace" > /tmp/.is_codespace_env.txt # Used by execution script to verify if we are running in a codespace docker environment
SHELL ["conda", "run", "/bin/bash", "-c"]
RUN pip install --upgrade pip
RUN pip install --upgrade \
    snowflake-connector-python[pandas] \
    snowflake-sqlalchemy

#Setting up Snowpark Python conda environment
FROM installer AS deps
COPY environment.yml* /tmp/installation-scripts/
RUN conda create -n snowparkenv -c https://repo.anaconda.com/pkgs/snowflake python=3.8
SHELL ["conda", "run", "-n", "snowparkenv", "/bin/bash", "-c"]
RUN /opt/conda/bin/conda env update -f /tmp/installation-scripts/environment.yml

#Deploying Snowflake Connectors and Drivers
COPY install_snowflake.sh* /tmp/installation-scripts/
USER root
SHELL ["/bin/bash", "-c"]
RUN chmod +x /tmp/installation-scripts/install_snowflake.sh \
    && /tmp/installation-scripts/install_snowflake.sh \
    && rm -rf /tmp/installation-scripts/*

# Used by execution script to verify if we are running in a codespace docker environment 
RUN echo "running in codespace" > /tmp/.is_codespace_env.txt 
