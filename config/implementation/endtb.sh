#!/bin/bash

# Variables required by Bahmni installer

export IMPLEMENTATION_NAME="endtb"

# Variables used by pih-deployment

export INITIAL_DATABASE_URL="https://bahmni-repo.twhosted.com/endtb/release-1.0/mysql_dump.sql"
export IMPLEMENTATION_CONFIG_ZIP_URL="https://bahmni-repo.twhosted.com/endtb/release-1.0/endtb_config.zip"

export TRANSLATIONS_REPO_URL="https://github.com/PIH/endtb-config.git"
export TRANSLATIONS_REPO_NAME="endtb-config"

export PRODUCTION_FOLDER="/home/jmbabazi/deploy-production"