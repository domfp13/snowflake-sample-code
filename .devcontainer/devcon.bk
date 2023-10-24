# Use an existing image as a base
FROM mcr.microsoft.com/devcontainers/anaconda:0.204-3 as base

# Add metadata
LABEL maintainer="Enrique Plata"

# Set environment variables to ensure Python doesn't create .pyc files
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Update the container OS, install curl and OpenSSL
FROM base as packageinstaller
USER root
RUN apt-get update && \
    apt-get -y install curl --no-install-recommends && \
    apt-get autoremove -y && \
    apt-get clean -y && \
    rm -rf /var/lib/apt/lists/*

# Set the LD_LIBRARY_PATH and OPENSSL_LIB_DIR environment variables
ENV LD_LIBRARY_PATH /usr/local/lib:$LD_LIBRARY_PATH
ENV OPENSSL_LIB_DIR /usr/local/lib

# Setting up Snowpark conda environment
#FROM packageinstaller AS condadeps
#COPY environment.yml /tmp/installation-scripts/
#RUN /opt/conda/bin/conda env update --name base -f /tmp/installation-scripts/environment.yml

# Copy environment.yml (if found) to a temp location so we update the environment. Also
# copy "noop.txt" so the COPY instruction does not fail if no environment.yml exists.
# COPY ./environment.yml* ./noop.txt /tmp/conda-tmp/
# RUN if [ -f "/tmp/conda-tmp/environment.yml" ]; then umask 0002 && /opt/conda/bin/conda env update -n base -f /tmp/conda-tmp/environment.yml; fi \
#     && rm -rf /tmp/conda-tmp

# RUN conda install snowflake-snowpark-python numpy=1.23.5 pandas=1.5.2 openpyxl=3.0.10 xlrd=2.0.1 --yes

# [Optional] Uncomment this section to install additional OS packages.
# RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
#     && apt-get -y install --no-install-recommends <your-package-list-here>
