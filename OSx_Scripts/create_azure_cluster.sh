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

for ((i=1; i<=$total_nodes; i++))
do
	#create vm
	echo "Working on instance: $i"
    cmd="azure vm create -l $region -z Standard_D11 -e $i -n $vm_name_prefix-$i -w $vnet_name -c $service_name -t $auth_cert_public -g $vm_admin_account_name -P -s $subscription_id $image_name"
    echo "RUNNING:" $cmd 
    eval $cmd
    sleep 120

	#download
	echo "DOWNLOADING COUCHBASE SERVER"
	cmd="ssh -p $i $vm_admin_account_name@$service_name.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'sudo wget \"$couchbase_download\" -O $couchbase_binary'"
	echo "RUNNING:" $cmd
	eval $cmd

	#install
	echo "install 4.0"
	cmd="ssh -p $i $vm_admin_account_name@$service_name.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'sudo dpkg -i $couchbase_binary'"
	echo "RUNNING:" $cmd
	eval $cmd
	sleep 30

	#init-cluster on first node
	if [ $i -eq 1 ]
	then 
        #init-cluster on first node and add-node on rest of the nodes
		echo "##### GETTING FIRST NODE IP #####"
        cmd="ssh -p $i $vm_admin_account_name@$service_name.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'ifconfig | grep 10.0.0. | cut -d\":\" -f 2 | cut -d\" \" -f 1'"
        echo "RUNNING:" $cmd
        first_node_ip=$(eval $cmd)  
        echo "FIRST NODE IP:  $first_node_ip"

		echo "##### RUNNING INIT #####"
		cmd="ssh -p $i $vm_admin_account_name@$service_name.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no /opt/couchbase/bin/couchbase-cli cluster-init -c $first_node_ip:8091 --cluster-username=$couchbase_admin_account_name --cluster-password=$couchbase_admin_account_password --cluster-init-ramsize=$cluster_ramsize --services=$node_services --cluster-index-ramsize=$cluster_index_ramsize"
		echo "RUNNING:" $cmd
		eval $cmd
	else
        #add-cluster on non-first node
        cmd="ssh -p $i $vm_admin_account_name@$service_name.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'ifconfig | grep 10.0.0. | cut -d\":\" -f 2 | cut -d\" \" -f 1'"
        echo "RUNNING:" $cmd
        node_ip=$(eval $cmd)  
        echo "NODE IP: $node_ip"

		echo "##### RUNNING ADD #####"
		cmd="ssh -p $i $vm_admin_account_name@$service_name.cloudapp.net -i $auth_cert_private /opt/couchbase/bin/couchbase-cli server-add -c $first_node_ip:8091 -u $couchbase_admin_account_name -p $couchbase_admin_account_password --server-add=$node_ip:8091 --server-add-username=$couchbase_admin_account_name --server-add-password=$couchbase_admin_account_password --services=$node_services"
		echo "RUNNING:" $cmd
		eval $cmd
	fi
done

#rebalance cluster
echo "##### RUNNING REBALANCE #####"
cmd="ssh -p 1 $vm_admin_account_name@$service_name.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no /opt/couchbase/bin/couchbase-cli rebalance -c $first_node_ip:8091 -u $couchbase_admin_account_name -p $couchbase_admin_account_password"
echo "RUNNING:" $cmd
eval $cmd

echo "SETUP COMPLETE!"
echo "VM Account Name:" $vm_admin_account_name
echo "Couchbase Admin Account:" $couchbase_admin_account_name
echo "Couchbase Admin Password:" $couchbase_admin_account_password

