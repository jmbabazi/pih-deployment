# pih-deployment
Includes Ansible playbooks and system configurations for deploying different bahmni implementations

# Deploy to Vagrant box
* vagrant box add vagrant-centos-6.7.box https://github.com/CommanderK5/packer-centos-template/releases/download/0.6.7/vagrant-centos-6.7.box
* vagrant up
* vagrant ssh
* sudo su -
* cd /vagrant/
* ./deploy.sh implementation_name 
- ./deploy.sh default 
- ./deploy.sh endtb


After the installation the OpenMRS and Bahmni apps would be accessible via the following URLs:
* http://192.168.33.21:8080/openmrs
* https://192.168.33.21/bahmni/home/#/dashboard
