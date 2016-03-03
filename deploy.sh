#!/bin/bash

BIN_PATH="$PWD"
IMPLEMENTATION_NAME="$1"
default_environment="test"
ENV_TYPE=${2:$default_environment}

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
		cd "$bin_path"
	else
	    echo "ansible is already installed"
	fi
}

install_bahmni_installer(){
	rm -rf /etc/bahmni-installer
	yum remove -y bahmni-installer
	ansible-playbook playbooks/bahmni-installer.yml
}

pre_install_config(){
	echo "Downloading the implementation config"
	ansible-playbook playbooks/implementation-config.yml --extra-vars "implementation_name=$IMPLEMENTATION_NAME"  --tags "pre-install"
}

post_install_config(){
	echo "Downloading the implementation config"
	bahmni stop
	ansible-playbook playbooks/implementation-config.yml --extra-vars "implementation_name=$IMPLEMENTATION_NAME"  --tags "post-install"
	bahmni start
}

deploy(){
	cp -f group_vars/* /etc/bahmni-installer/	
	cd /etc/bahmni-installer && bahmni install inventory
}

install_conditional_packages(){	
	ansible-playbook playbooks/$ENV_TYPE.yml --extra-vars "env_name=$ENV_TYPE"
}

echo "Deploying a new $ENV_TYPE environment for $IMPLEMENTATION_NAME"
install_ansible
install_bahmni_installer
pre_install_config
deploy
post_install_config
