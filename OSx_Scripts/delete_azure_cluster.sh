#!/bin/sh

#read settings
source ./settings.sh

#warning
echo "WARNING: This will wipe out your cluster nodes, jumpbox and delete all your data on VMs starting with the `"$vm_name_prefix"` prefix. vnet "$vnet_name" will also be cleaned up if no other node on the same vnet remains. [y/n]"
read yes_no

if [ $yes_no == 'y' ]
then
    #login
    azure login -u $azure_account

    #set mode to asm
    azure config mode asm

if [ $disable_jumpbox -ne 1 ]
    then 
        echo "CMD: azure vm delete "$vm_name_prefix"-jumpbox -q"
        if [ $enable_fast_delete == 1 ]
        then
            yes_no='y'
        else
            echo "CONFIRM DELETING JUMPBOX: "$vm_name_prefix"-jumpbox [y/n]"
            read yes_no
        fi
        
        if [ $yes_no == 'y' ]
        then
            echo "DELETING JUMPBOX: "$vm_name_prefix"-jumpbox"
            azure vm delete $vm_name_prefix-jumpbox -q
        else
            echo "SKIPPED CLEANUP STEP. DID NOT DELETE JUMPBOX: "$vm_name_prefix"-jumpbox"
        fi         
    else   
        echo "JUMPBOX DISABLE. SKIPPING JUMPBOX."
fi

    #loop to clean up all nodes.
    for ((i=1; i<=$couchbase_total_nodes; i++))
    do
        echo "CMD: azure vm delete "$vm_name_prefix"-"$i" -q"
        if [ $enable_fast_delete == 1 ]
        then
            yes_no='y'
        else
            echo "CONFIRM DELETING JUMPBOX: "$vm_name_prefix"-"$i" [y/n]"
            read yes_no
        fi
            
        if [ $yes_no == 'y' ]
        then
            echo "DELETING COUCHBASE NODE: "$vm_name_prefix"-"$i
            azure vm delete $vm_name_prefix-$i -q
        else
            echo "SKIPPED CLEANUP STEP. DID NOT DELETE COUCHBASE NODE: "$vm_name_prefix"-"$i
        fi
    done

    #delete the vnet
        echo "CMD: azure network vnet delete "$vnet_name" -q"
        if [ $enable_fast_delete == 1 ]
        then
            yes_no='y'
        else
            echo "CONFIRM DELETING VNET: "$vnet_name" [y/n]"
            read yes_no
        fi
            
        if [ $yes_no == 'y' ]
        then
            azure network vnet delete $vnet_name -q
        else
            echo "SKIPPED CLEANUP STEP. DID NOT DELETE VNET: "$vnet_name
        fi
    echo "##############################################################################"
    echo "INFO: CLEANUP COMPLETED"
else
    echo "INFO: CLEANUP CANCELLED"
fi