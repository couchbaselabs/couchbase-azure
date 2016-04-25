#!/bin/sh

#read settings
source ./my_settings.sh

#may need to remove known hosts file if exists.
if [ $remove_known_hosts -eq 1 ]
    then
        rm ~/.ssh/known_hosts
fi

#switch azure mode to asm
azure config mode asm
azure login -u $azure_account

#create vnet with large vm count - 1024
azure network vnet create --vnet $vnet_name -l "west US" -e 10.0.0.1 -m 1024

#create jumpbox vm
if [ $disable_jumpbox -ne 1 ]
    then
	echo "INFO: Working on jumpbox instance."
    cmd="azure vm create -l $region -z $jumpbox_vm_sku -n $vm_name_prefix-jumpbox -w $vnet_name -c $service_name -r -g $jumpbox_vm_admin_account_name -p $jumpbox_vm_admin_account_password -s $azure_subscription_id $jumpbox_image_name"
    echo "INFO: RUNNING:" $cmd 
    eval $cmd
fi

for ((i=1; i<=$couchbase_total_nodes; i++))
do
	#create vm
	echo "INFO: Working on instance: $i"
    cmd="azure vm create -l $region -z $couchbase_vm_sku -e $i -n $vm_name_prefix-$i -w $vnet_name -c $service_name -t $vm_auth_cert_public -g $couchbase_vm_admin_account_name -P -s $azure_subscription_id $couchbase_vm_image_name"
    echo "INFO: RUNNING:" $cmd 
    eval $cmd
    sleep 120

	#download
	echo "INFO: Downloading Couchbase Server"
	cmd="ssh -p $i $couchbase_vm_admin_account_name@$service_name.cloudapp.net -i $vm_auth_cert_private -o StrictHostKeyChecking=no 'sudo wget \"$couchbase_download\" -O $couchbase_binary'"
	echo "INFO: RUNNING:" $cmd
	eval $cmd

	#install
	echo "INFO: Installing Couchbase Server"
	cmd="ssh -p $i $couchbase_vm_admin_account_name@$service_name.cloudapp.net -i $vm_auth_cert_private -o StrictHostKeyChecking=no 'sudo dpkg -i $couchbase_binary'"
	echo "INFO: RUNNING:" $cmd
	eval $cmd
	sleep 30

	#init-cluster on first node
	if [ $i -eq 1 ]
	then 
        #init-cluster on first node and add-node on rest of the nodes
		echo "INFO: ##### GETTING FIRST NODE IP #####"
        cmd="ssh -p $i $couchbase_vm_admin_account_name@$service_name.cloudapp.net -i $vm_auth_cert_private -o StrictHostKeyChecking=no 'ifconfig | grep 10.0.0. | cut -d\":\" -f 2 | cut -d\" \" -f 1'"
        echo "INFO: RUNNING:" $cmd
        first_node_ip=$(eval $cmd)  
        echo "INFO: FIRST NODE IP:  $first_node_ip"

		echo "##### RUNNING INIT #####"
		cmd="ssh -p $i $couchbase_vm_admin_account_name@$service_name.cloudapp.net -i $vm_auth_cert_private -o StrictHostKeyChecking=no /opt/couchbase/bin/couchbase-cli cluster-init -c $first_node_ip:8091 --cluster-username=$couchbase_admin_account_name --cluster-password=$couchbase_admin_account_password --cluster-init-ramsize=$couchbase_cluster_ramsize --services=$couchbase_node_services --cluster-index-ramsize=$couchbase_cluster_index_ramsize"
		echo "INFO: RUNNING:" $cmd
		eval $cmd
	else
        #add-cluster on non-first node
        cmd="ssh -p $i $couchbase_vm_admin_account_name@$service_name.cloudapp.net -i $vm_auth_cert_private -o StrictHostKeyChecking=no 'ifconfig | grep 10.0.0. | cut -d\":\" -f 2 | cut -d\" \" -f 1'"
        echo "INFO: RUNNING:" $cmd
        node_ip=$(eval $cmd)  
        echo "INFO: NODE IP: $node_ip"

		echo "##### RUNNING ADD #####"
		cmd="ssh -p $i $couchbase_vm_admin_account_name@$service_name.cloudapp.net -i $vm_auth_cert_private /opt/couchbase/bin/couchbase-cli server-add -c $first_node_ip:8091 -u $couchbase_admin_account_name -p $couchbase_admin_account_password --server-add=$node_ip:8091 --server-add-username=$couchbase_admin_account_name --server-add-password=$couchbase_admin_account_password --services=$couchbase_node_services"
		echo "INFO: RUNNING:" $cmd
		eval $cmd
	fi
done

#rebalance cluster
echo "INFO: ##### RUNNING REBALANCE #####"
cmd="ssh -p 1 $couchbase_vm_admin_account_name@$service_name.cloudapp.net -i $vm_auth_cert_private -o StrictHostKeyChecking=no /opt/couchbase/bin/couchbase-cli rebalance -c $first_node_ip:8091 -u $couchbase_admin_account_name -p $couchbase_admin_account_password"
echo "INFO: RUNNING:" $cmd
eval $cmd

echo "INFO: SETUP COMPLETE!"
echo "##############################################################################"
if [ $disable_jumpbox -ne 1 ]
    then
		echo "INFO: Connect to Jumpbox and Open Browser to Couchbase Web Console at  http://"$first_node_ip":8091. Login with couchbase server account name and password below."
		echo "INFO: To Connect to the Jumpbox:"
		echo "INFO: JUMPBOX VM:" $service_name".cloudapp.net at RDP Port 3398 " 
		echo "INFO: JUMPBOX VM Account Name:" $jumpbox_vm_admin_account_name
		echo "INFO: JUMPBOX VM Account Password:" $jumpbox_vm_admin_account_password
	else
		echo "INFO: Recommended: Use Another VM within the same vnet name ("$vnet_name") and Open Browser to Couchbase Web Console at http://"$first_node_ip":8091. Login with couchbase server account name and password below."
		echo "INFO: NOT Recommended: Expose 8091 and Open Browser to Couchbase Web Console at  http://"$service_name".cloudapp.net:8091. Login with couchbase server account name and password below."
fi
echo "INFO: COUCHBASE SERVER Admin Account:" $couchbase_admin_account_name
echo "INFO: COUCHBASE SERVER Admin Password:" $couchbase_admin_account_password
echo "##############################################################################"
echo "INFO: To SSH Into Cluster Nodes: ssh -p <port> " $couchbase_vm_admin_account_name"@$service_name.cloudapp.net -i "$vm_auth_cert_private" -o StrictHostKeyChecking=no" 
echo "INFO: COUCHBASE VM Account Name:" $couchbase_vm_admin_account_name
echo "##############################################################################"
echo "INFO: RUN ./delete_azure_cluster.sh TO CLEANUP THE CLUSTER"

