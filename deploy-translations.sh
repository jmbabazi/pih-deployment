#!/bin/bash

bin_path="$PWD"

cp -f inventory/translations/* group_vars/	 	
ansible-playbook playbooks/deploy-translations.yml	