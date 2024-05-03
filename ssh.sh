#!/bin/bash

export WGIP=`cat terraform/terraform.tfstate | jq -r '.resources[0] .instances[0] .attributes .public_ip_address'`

ssh ubuntu@$WGIP -i id_rsa
