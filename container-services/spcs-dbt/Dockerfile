# Use the slim variant of the Python 3.10.0 Docker image as the base image
FROM python:3.10.0-slim

# Set environment variables
# APP_HOME: The directory where the application will be located inside the Docker container
# PYTHONDONTWRITEBYTECODE: Prevents Python from writing .pyc files
# PYTHONUNBUFFERED: Prevents Python from buffering stdout and stderr
ENV APP_HOME /usr/src/app
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Update the package lists for upgrades for packages that need upgrading, as well as new packages that have just come to the repositories
# Install the locales package, which allows you to set the locale and language settings to use in your environment
# Enable the en_US.UTF-8 locale
# Generate the locales
# Set the default locale to en_US.utf8
# Install the gcc package
# Clean up the package lists to free up disk space
RUN apt-get update && \
    apt-get install -y locales && \
    sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen && \
    locale-gen && \
    echo LANG=en_US.utf8 > /etc/default/locale && \
    apt-get install -yy gcc && \
    apt-get clean  && \
    rm -rf /var/lib/apt/lists/*

# Upgrade pip to the latest version
# Install the dbt-snowflake package, which provides support for Snowflake in dbt (data build tool)
RUN pip install --upgrade pip && \
    pip install dbt-snowflake

# Set the working directory to APP_HOME
# All subsequent commands will be run from this directory
WORKDIR $APP_HOME

# Copy the entrypoint.sh script from your host to the APP_HOME directory in the Docker image
COPY entrypoint.sh $APP_HOME/entrypoint.sh

# Use the RUN command to make the entrypoint.sh script executable
RUN chmod +x $APP_HOME/entrypoint.sh

# Set the entrypoint of the Docker image to the entrypoint.sh script
# When a container is started from this image, it will execute this script
ENTRYPOINT [ "./entrypoint.sh" ]