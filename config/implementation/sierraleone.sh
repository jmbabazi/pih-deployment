#!/bin/bash

# Variables required by Bahmni installer

export IMPLEMENTATION_NAME="sierraleone"
export BAHMNI_NTP_TIMEZONE="Africa/Freetown"

# Variables used by pih-deployment

export INITIAL_DATABASE_URL="https://raw.githubusercontent.com/Bahmni/bahmni-package/master/openmrs/resources/openmrs_clean_dump.sql"
export IMPLEMENTATION_CONFIG_REPOSITORY="https://github.com/PIH/wellbody-config.git"
export IMPLEMENTATION_CONFIG_REPOSITORY_VERSION="master"
