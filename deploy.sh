#!/bin/bash

WORKING_DIRECTORY="$PWD"
INSTALL_DIRECTORY="/etc/pih"
SCRIPT_DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
CONFIG_FILE="$INSTALL_DIRECTORY/config.sh";
BAHMNI_OPENMRS_CONFIG_DIR="/var/www/bahmni_config/openmrs"
BAHMNI_INSTALLER_DIR="/etc/bahmni-installer"
SETUP_YAML_FILE="$BAHMNI_INSTALLER_DIR/setup.yml"
INVENTORY_FILE="$BAHMNI_INSTALLER_DIR/inventory"

validateSetup() {
	# Ensure script runs as root/sudo
	if [[ $EUID -ne 0 ]]; then
		echo "This script must be run as root" 1>&2
		exit 1
	fi

	# Ensure script is installed into $INSTALL_DIRECTORY/deployment
	if [[ $SCRIPT_DIR != "$INSTALL_DIRECTORY/deployment" ]]; then
		echo "Expected this script to be located in $INSTALL_DIRECTORY/deployment.  Please check setup instructions." 1>&2
		exit 1
	fi
}

installDependentPackages() {
	yum install -y -q unzip
	yum install -y -q tar
	yum install -y -q wget
	yum install -y -q curl
	yum install -y -q git
}

collectEnvironmentSettings() {
	# Read in the implementation name
	read -e -p "Specify implementation name to install (endtb, sierraleone): "  -i "" IMPLEMENTATION_NAME
	while ! [ -f "$SCRIPT_DIR/config/implementation/$IMPLEMENTATION_NAME.sh" ]; do
		read -e -p "Invalid implementation specified.  Please choose based on options in $SCRIPT_DIR/config/implementation:  " IMPLEMENTATION_NAME
	done

	# Read in the environment type
	read -e -p "Specify environment type to install (production, test, dev): "  -i "" ENVIRONMENT_NAME
	while ! [ -f "$SCRIPT_DIR/config/environment/$ENVIRONMENT_NAME.sh" ]; do
		read -e -p "Invalid environment specified.  Please choose based on options in $SCRIPT_DIR/config/environment:  " ENVIRONMENT_NAME
	done

	# Write the input configuration settings to file for later reference
	echo "Storing configuration settings in $CONFIG_FILE"
	rm -fR $CONFIG_FILE
	touch $CONFIG_FILE
	echo "export IMPLEMENTATION_NAME=$IMPLEMENTATION_NAME" >> $CONFIG_FILE
	echo "export ENVIRONMENT_NAME=$ENVIRONMENT_NAME" >> $CONFIG_FILE
}

loadEnvironmentVariables() {
	echo "Loading Environment Variables..."
	source "$CONFIG_FILE"
	source "$SCRIPT_DIR/config/common.sh"
	source "$SCRIPT_DIR/config/implementation/$IMPLEMENTATION_NAME.sh"
	source "$SCRIPT_DIR/config/environment/$ENVIRONMENT_NAME.sh"
}

installBahmniInstaller() {
	local BAHMNI_RPM="bahmni-installer-$BAHMNI_VERSION.noarch.rpm"
	rm -rf /etc/bahmni-installer
	yum remove -y bahmni-installer
	wget $BAHMNI_REPO_URL/$BAHMNI_RPM -P /tmp
	yum install -y -q /tmp/$BAHMNI_RPM
	rm -fR /tmp/$BAHMNI_RPM
}

outputToSetupYaml() {
	echo "$1" >> "$SETUP_YAML_FILE"
}

outputIfSetToSetupYaml() {
	VAR_NAME="$1"
	VAR_VALUE="$2"
	if ! [ -z "$VAR_VALUE" ]; then
		echo "$VAR_NAME: $VAR_VALUE" >> "$SETUP_YAML_FILE"
	fi
}

installSetupYaml() {
	echo "Installing new setup yaml to $SETUP_YAML_FILE"
	rm -fR $SETUP_YAML_FILE
	touch $SETUP_YAML_FILE

	loadEnvironmentVariables

	outputToSetupYaml ""
	outputToSetupYaml "# Variables required by Bahmni installer"
	outputToSetupYaml ""
	outputIfSetToSetupYaml "implementation_name" "$IMPLEMENTATION_NAME"
	outputIfSetToSetupYaml "bahmni_ntp_timezone" "$BAHMNI_NTP_TIMEZONE"
	outputIfSetToSetupYaml "bahmni_repo_url" "$BAHMNI_REPO_URL"
	outputIfSetToSetupYaml "bahmni_installer_directory" "$BAHMNI_INSTALLER_DIRECTORY"
	outputIfSetToSetupYaml "bahmni_deployment_artifacts" "$BAHMNI_DEPLOYMENT_ARTIFACTS"
	outputIfSetToSetupYaml "mysql_root_password" "$MYSQL_ROOT_PASSWORD"
	outputIfSetToSetupYaml "openmrs_db_password" "$OPENMRS_DB_PASSWORD"
	outputIfSetToSetupYaml "openmrs_server_options" "$OPENMRS_SERVER_OPTIONS"
}

installInventory() {
	echo "Installing new inventory file to $INVENTORY_FILE"
	rm $INVENTORY_FILE
	cp $SCRIPT_DIR/inventory/$IMPLEMENTATION_NAME $INVENTORY_FILE
}

updateBahmniConfiguration() {
	echo "Updating Bahmni Configuration files for environment"
	installSetupYaml
	installInventory
}

installStarterDatabase() {
	echo "Installing started database from URL: $INITIAL_DATABASE_URL"
	wget $INITIAL_DATABASE_URL -O $BAHMNI_DEPLOYMENT_ARTIFACTS/mysql_dump.sql
}

installImplementationConfig() {
	cd $BAHMNI_DEPLOYMENT_ARTIFACTS

	# Option 1: Clone from github
	if ! [ -z "$IMPLEMENTATION_CONFIG_REPOSITORY" ]; then
		echo "Installing Implementation Config from git: $IMPLEMENTATION_CONFIG_REPOSITORY"
		git clone $IMPLEMENTATION_CONFIG_REPOSITORY $IMPLEMENTATION_NAME_config
		if ! [ -z "$IMPLEMENTATION_CONFIG_REPOSITORY_VERSION" ]; then
			cd $IMPLEMENTATION_NAME_config
			echo "Checking out version: $IMPLEMENTATION_CONFIG_REPOSITORY_VERSION"
			git checkout $IMPLEMENTATION_CONFIG_REPOSITORY_VERSION
			cd ..
		fi

	# Option 2: Download as a zip file from remote URL (resource must be named {{ implementation_name }}_config.zip)
	elif ! [ -z "$IMPLEMENTATION_CONFIG_ZIP_URL" ]; then
		echo "Installing Implementation Config from zip url: $IMPLEMENTATION_CONFIG_ZIP_URL"
		wget $IMPLEMENTATION_CONFIG_ZIP_URL -P .
		unzip $IMPLEMENTATION_NAME_config.zip

	# Option 3: Copy from another folder on the filesystem (mostly used in development mode to copy from mounted vagrant folder)
	elif ! [ -z "$IMPLEMENTATION_CONFIG_DIR" ]; then
		echo "Installing Implementation Config by copying from: $IMPLEMENTATION_CONFIG_DIR"
		cp -a $IMPLEMENTATION_CONFIG_DIR .
	fi
}


deployBahmni() {
	echo "Deploying latest distribution"
	cd $INSTALL_DIRECTORY/deployment
	loadEnvironmentVariables
	installBahmniInstaller
	updateBahmniConfiguration
	installStarterDatabase
	installImplementationConfig
	bahmni install inventory
	cd $WORKING_DIRECTORY
}

install() {
	if hash bahmni 2>/dev/null; then
		echo "Distribution already installed"
		exit 1;
	fi
	collectEnvironmentSettings
	installDependentPackages
	deployBahmni
}

updateDistribution() {
	echo "Updating distribution"
	cd $INSTALL_DIRECTORY/deployment
	git pull --rebase
	deployBahmni
}

updateConfig() {
	# This emulates the code behind the "bahmni update-config" command, which seems to run too slow to use regularly
	if [ -d "$IMPLEMENTATION_CONFIG_DIR" ]; then
		echo "Copying configuration from $IMPLEMENTATION_CONFIG_DIR/openmrs to $BAHMNI_OPENMRS_CONFIG_DIR"
		rm -fR $BAHMNI_OPENMRS_CONFIG_DIR
		cp -rf $IMPLEMENTATION_CONFIG_DIR/openmrs $BAHMNI_OPENMRS_CONFIG_DIR
		chmod -R 755 $BAHMNI_OPENMRS_CONFIG_DIR
		chown -R bahmni: $BAHMNI_OPENMRS_CONFIG_DIR
		ln -sf $BAHMNI_OPENMRS_CONFIG_DIR/obscalculator /opt/openmrs/obscalculator
		ln -sf $BAHMNI_OPENMRS_CONFIG_DIR/ordertemplates /opt/openmrs/ordertemplates
		ln -sf $BAHMNI_OPENMRS_CONFIG_DIR/encounterModifier /opt/openmrs/encounterModifier
		ln -sf $BAHMNI_OPENMRS_CONFIG_DIR/patientMatchingAlgorithm /opt/openmrs/patientMatchingAlgorithm
		rm -fR /opt/openmrs/bahmni_config
		ln -sf /var/www/bahmni_config /opt/openmrs/bahmni_config
	else
		echo "No local configuration found to update"
	fi
}

runLiquibase() {
	if [ -d "$SOURCE_DIRECTORY" ]; then
		echo "Executing the liquibase file at $BAHMNI_OPENMRS_CONFIG_DIR/migrations/liquibase.xml"
		source /opt/bahmni-installer/bahmni-playbooks/roles/implementation-config/files/run-implementation-openmrs-liquibase.sh
	else
		echo "No local liquibase found to update"
	fi
}

# BEGIN SCRIPT EXECUTION

validateSetup

# Following installation, this config file contains the environment variables collected. Source these before running the script
if [ -f "$CONFIG_FILE" ]; then
	loadEnvironmentVariables
fi

case $1 in
	install)
		install
		;;

	update-distribution)
		updateDistribution
  		;;

  	update-local)
  		updateConfig
  		runLiquibase
		;;

  	update-local-config)
  		updateConfig
  		;;

  	run-liquibase)
  		runLiquibase
  		;;

  	restart)
  		echo "Restarting Bahmni"
  		bahmni stop
  		bahmni start
  		;;

  	log)
  		tail -f /opt/openmrs/log/openmrs.log
  		;;

	*)
		echo "USAGE:"
		echo ""
		echo "  install:                Installs the distribution"
		echo "  update-distribution:    Re-runs the distribution with the latest versions"
		echo "  update-local:           Development tool to copy config and execute liquibase"
		echo "  update-local-config:    Development tool to copy config only, does not execute liquibase"
		echo "  run-liquibase:          Executes the liquibase script located in $BAHMNI_OPENMRS_CONFIG_DIR/migrations"
		echo "  restart:                Restarts Bahmni"
		echo "  log:                    Tails the OpenMRS log file"
		echo ""
		;;
esac
