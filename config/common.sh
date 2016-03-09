#!/bin/bash

# Variables required by Bahmni installer

export BAHMNI_REPO_URL="https://bahmni-repo.twhosted.com/rpm/bahmni/"
export BAHMNI_INSTALLER_DIRECTORY="/etc/bahmni-installer"
export BAHMNI_DEPLOYMENT_ARTIFACTS="$BAHMNI_INSTALLER_DIRECTORY/deployment-artifacts"

export BAHMNI_NTP_TIMEZONE="America/New_York"
export BAHMNI_VERSION="0.80-139"

export MYSQL_ROOT_PASSWORD="password"
export OPENMRS_DB_PASSWORD="password"
export OPENMRS_SERVER_OPTIONS="-Xms1024m -Xmx2048m -XX:PermSize=512m -XX:MaxPermSize=1024m"

# Variables used by pih-deployment

export INITIAL_DATABASE_URL="https://raw.githubusercontent.com/Bahmni/bahmni-package/master/openmrs/resources/openmrs_clean_dump.sql"

