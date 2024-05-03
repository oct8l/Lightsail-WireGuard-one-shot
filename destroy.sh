#!/bin/bash

#########################
## Delete the SSH keys ##
rm id_rsa*
#########################


#############################################
## Set a junk variable so destroying works ##
export TF_VAR_pubkey=junk
#############################################


############################################################
## Go into the Terraform directory and provision the host ##
cd terraform
terraform destroy -auto-approve
############################################################


######################################################################
## Go into the Ansible directory and remove the client config files ##
cd ../ansible
rm -rf clients/
######################################################################


####################################################################
## Notify about the packages installed in the `run-all.sh` script ##
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")

printf "\e[0m\e[1mIf you no longer need the Python packages, you can uninstall them with:\e[0m\n\n"
printf "\e[33mpip uninstall -r \"%s/requirements.txt\" -y\e[0m\n\n" "${SCRIPT_DIR}"

printf "\e[0m\e[1mIf you no longer need the Ansible roles and collections, you can uninstall them with:\e[0m\n\n"
printf "\e[33m"
echo "grep 'name:' \"%s/ansible/requirements.yml\" | awk '{print \$3}' | sed 's/\\r\$//' | xargs -I {} ansible-galaxy remove {}" "${SCRIPT_DIR}"
printf "\e[0m\n\n"
####################################################################


printf "\n\e[32m---------\nALL GONE\n---------\e[0m\n\n"
