#!/bin/bash

install_ansible(){
	if ! rpm -qa | grep -qw ansible;
	then
	    echo "install ansible"
	    cd /tmp
		wget http://download.fedoraproject.org/pub/epel/6/x86_64/epel-release-6-8.noarch.rpm
		rpm -ivh epel-release-6-8.noarch.rpm
		yum repolist
		# yum -y update
		yum -y install ansible
		echo "ansible has been installed"
	else
	    echo "ansible is already installed"
	fi
}

copy_artifacts(){
	echo "Copying the files from inventory/$1/"
	mkdir -p group_vars
	mkdir -p rpms
	cp -f inventory/"$1"/local group_vars/	
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

copy_db_dump(){
	echo "Dropping the openmrs database"
	ansible bahmni-emr-db -i /etc/bahmni-installer/inventory -m shell -a "mysql -uroot -ppassword openmrs -e 'drop database openmrs'"
	wget --no-check-certificate $1 -O /etc/bahmni-installer/deployment-artifacts/mysql_dump.sql
}

deploy(){
	cd /etc/bahmni-installer && bahmni install inventory
}

echo $1
install_ansible
copy_artifacts $1
install_bahmni_installer
copy_implementation_config $1