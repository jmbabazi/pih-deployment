#!/bin/bash

# Variables required by Bahmni installer

export BAHMNI_NTP_TIMEZONE="America/New_York"
export OPENMRS_SERVER_OPTIONS="-Xms1024m -Xmx2048m -XX:PermSize=512m -XX:MaxPermSize=1024m -agentlib:jdwp=transport=dt_socket,address=8000,server=y,suspend=n"

# Variables used by pih-deployment

export IMPLEMENTATION_CONFIG_REPOSITORY=""
export IMPLEMENTATION_CONFIG_REPOSITORY_VERSION=""
export IMPLEMENTATION_CONFIG_ZIP_URL=""
export IMPLEMENTATION_CONFIG_DIR="/vagrant/openmrs"
