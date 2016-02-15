# pih-deployment
Includes Ansible playbooks and system configurations for deploying different bahmni implementations

# Deploy to Vagrant box
* vagrant up
* vagrant ssh
* sudo su -
* cd /vagrant/
* ./deploy.sh default 
  
* ./deploy.sh [implementation_name] (e.g. ./deploy.sh endtb)


After the installation the OpenMRS and Bahmni apps would be accessible via the following URLs:
* http://192.168.33.21:8080/openmrs
* https://192.168.33.21/bahmni/home/#/dashboard
