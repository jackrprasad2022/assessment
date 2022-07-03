#!/bin/bash 
# bash script to obtain the json metadata of the instance in azure .
# Install the azure cli in the linux machine and proceed 

# login into the azure subscription providign the service principal 

az login --service-principal -u <app-id> -p <password-or-cert> --tenant <tenant>

rgroup="dummyresourcegroup"

vmname="vm-01"
# using the azure cli, getting the details of the VM in json format and putting into a file in local directory
az vm show -g $rgroup -n $vmname -o json > jsonvmfile

# show the contents of the json file
cat jsonvmfile


# to retrieve the value of a particular data key like "resources"
s
cat testjson | jq .resources


