#!/bin/bash

set -x

#############################################################################################
# Assume the Inventory file is always unchanged so there isn't always a change to commit ####
#### This definitely can be improved because I think you can specify an IP address ##########
#### instead of using the whole inventory file, but that's a later me problem ###############
git update-index --assume-unchanged ansible/inventory
#############################################################################################


##################################################################
## Make sure we're in the root directory when the script starts ##
SCRIPT_DIR=$(dirname "$(readlink -f "$0")")
cd "${SCRIPT_DIR}"
##################################################################


#################################
## Install the galaxy packages ##
ansible-galaxy install -r ansible/requirements.yml
#################################


#############################
## Install the pip modules ##
pip install --user -r ansible/requirements.txt
#############################


###################################################
## Generate a new ed25519 key to use with the VM ##
ssh-keygen -t ed25519 -C "Lightsail WireGuard server $(date +%Y-%m-%d-%H-%M-%S)" -f ./id_rsa -N ""
export TF_VAR_pubkey=`cat ./id_rsa.pub`
rm ./id_rsa.pub
###################################################


############################################################
## Go into the Terraform directory and provision the host ##
cd terraform
terraform init
terraform apply -auto-approve
############################################################


######################################################################
## Export the IP of the Lightsail server as an environment variable ##
export WGIP=`cat terraform.tfstate | jq -r '.resources[0] .instances[0] .attributes .public_ip_address'`
######################################################################


#########################################################
## Export the interface the VM uses, since it can vary ##
while true; do
    WG_OUT_INTERFACE=$(ssh -o StrictHostKeyChecking=no ubuntu@$WGIP -i ../id_rsa 'sudo sed -n '\''/ethernets:/,/^  [a-z]/p'\'' /etc/netplan/*-cloud-init.yaml | sudo awk '\''{ print $1 }'\'' | sudo sed -n '\''2p'\'' | sudo sed '\''s/:$//'\''')
    if [ -n "$WG_OUT_INTERFACE" ]; then
        break
    fi
    sleep 5
done

export WG_OUT_INTERFACE
#########################################################


########################################################
## Go into the Ansible directory and run the playbook ##
cd ../ansible

### Add the correct/current IP to the inventory ###
printf "wg-host ansible_ssh_host=$WGIP\n" > inventory

### Run the playbook ###
ansible-playbook wireguard-server.yml
########################################################


#################################################################################
## Update the IP and private key in the wireguard config file that's generated ##
sed -i "s/wg-host/$WGIP/g" clients/wg-host/full-tunnel1.conf
sed -i "s@\[User\sPrivate\sKey\]@$PRIVKEY1@" clients/wg-host/full-tunnel1.conf
sed -i "s/wg-host/$WGIP/g" clients/wg-host/full-tunnel2.conf
sed -i "s@\[User\sPrivate\sKey\]@$PRIVKEY2@" clients/wg-host/full-tunnel2.conf
sed -i "s/wg-host/$WGIP/g" clients/wg-host/full-tunnel3.conf
sed -i "s@\[User\sPrivate\sKey\]@$PRIVKEY3@" clients/wg-host/full-tunnel3.conf
#################################################################################

printf "\nALL DONE\n\n"

set +x
