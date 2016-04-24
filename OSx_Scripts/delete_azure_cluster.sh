#!/bin/sh

#read settings
source ./my_settings.sh

#warning
echo "WARNING, This will wipe out your cluster and delete all your data. [y/n]"
read yes_no

if [ $yes_no == 'y' ]
then
    #login
    azure login -u $azure_account

    #set mode to asm
    azure config mode asm

    azure vm delete $vm_name_prefix-jumpbox -q

    #loop to clean up all nodes.
    for ((i=1; i<=$couchbase_total_nodes; i++))
    do
	    echo "DELETING INSTANCE: $i"
	    azure vm delete $vm_name_prefix-$i -q
    done

    #delete the vnet
    azure network vnet delete $vnet_name -q

else
    echo "CANCELLED"

fi