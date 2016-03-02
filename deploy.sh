#!/bin/bash

BIN_PATH="$PWD"
IMPLEMENTATION_NAME="$1"
ENV_TYPE="$2"

# TODO: Validate input arguments and/or prompt the user to enter them interactively

install_ansible(){
	if ! rpm -qa | grep -qw ansible;
	then
	    echo "installing ansible"
	    cd /tmp
		wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
		rpm -ivh epel-release-6-8.noarch.rpm
		yum repolist
		yum -y install ansible
		echo "ansible has been installed"
	else
	    echo "ansible is already installed"
	fi
}

copy_artifacts(){
	echo "Copying the files from inventory/$1/"
	cd "$BIN_PATH"
	mkdir -p group_vars
	mkdir -p rpms
	cp -f inventory/"$IMPLEMENTATION_NAME"/* group_vars/
}

install_bahmni_installer(){
	rm -rf /etc/bahmni-installer
	yum remove -y bahmni-installer
	ansible-playbook playbooks/bahmni-installer.yml
}

copy_implementation_config(){
	echo "Downloading the implementation config"
	ansible-playbook playbooks/implementation-config.yml
}

deploy(){
	cp -f group_vars/* /etc/bahmni-installer/	
	cd /etc/bahmni-installer && bahmni install inventory
}

install_crashplan(){
	echo "Installing install_crashplan"
}

install_conditional_packages(){
	if [[ "$ENV_TYPE" == "prod" ]];
	then
		install_crashplan
	fi
}

echo "Deploying a new $ENV_TYPE environment for $IMPLEMENTATION_NAME"
install_ansible
install_conditional_packages
copy_artifacts
install_bahmni_installer
copy_implementation_config
deploy
