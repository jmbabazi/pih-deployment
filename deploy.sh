#!/bin/bash

BIN_PATH="$PWD"

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
		cd "$BIN_PATH"
	else
	    echo "ansible is already installed"
	fi
}

install_translations() {
	ansible-playbook playbooks/deploy-translations.yml
}

install_wellbody() {
	ansible-playbook -i local playbooks/endtb.yml --extra-vars ""
}

install_ansible
install_wellbody