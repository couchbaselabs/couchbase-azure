#!/bin/sh

#couchbase settings
couchbase_download="https://onedrive.live.com/download?resid=EABC62172B7182F3!17815&authkey=!AMGtXgCL0HuO9Aw"
couchbase_binary="couchbase-server-enterprise_4.5.0-2083-ubuntu14.04_amd64.deb"
couchbase_admin_account_name="cb_dbadmin"
couchbase_admin_account_password="couchB@SE"
cluster_index_ramsize=4000
cluster_ramsize=4000
total_nodes=8

#azure settings
region="'west US'"
image_name="b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_4-LTS-amd64-server-20160314-en-us-30GB"
account="cb@cihangirbhotmail.onmicrosoft.com"
subscription_id="3d01005f-455d-4430-b930-8455310e1f65"
auth_cert_public="~/test.pub"
auth_cert_private="~/test.key"
vm_name_prefix="cbase"
vm_admin_account_name="cb_vmadmin"
vnet_name="cb_private1"

#misc
remove_known_hosts=1


#may need to remove known hosts file if exists.
if [ $remove_known_hosts -eq 1 ]
    then
        rm ~/.ssh/known_hosts
fi

#switch azure mode to asm
azure config mode asm
azure login -u $account

#create vnet with large vm count - 1024
azure network vnet create --vnet $vnet_name -l "west US" -e 10.0.0.1 -m 1024

for ((i=1; i<=$total_nodes; i++))
do
	#create vm
	echo "Working on instance: $i"
    cmd="azure vm create -l $region -z Standard_D11 -e $i -n $vm_name_prefix-$i -w $vnet_name -c couchbase-service -t $auth_cert_public -g $vm_admin_account_name -P -s $subscription_id $image_name"
    echo "RUNNING:" $cmd 
    eval $cmd
    sleep 120

	#download
	echo "DOWNLOADING COUCHBASE SERVER"
	cmd="ssh -p $i $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'sudo wget \"$couchbase_download\" -O $couchbase_binary'"
	echo "RUNNING:" $cmd
	eval $cmd

	#install
	echo "install 4.0"
	cmd="ssh -p $i $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'sudo dpkg -i $couchbase_binary'"
	echo "RUNNING:" $cmd
	eval $cmd
	sleep 30

	#init-cluster on first node
	if [ $i -eq 1 ]
	then 
        #init-cluster on first node and add-node on rest of the nodes
		echo "##### GETTING FIRST NODE IP #####"
        cmd="ssh -p $i $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'ifconfig | grep 10.0.0. | cut -d\":\" -f 2 | cut -d\" \" -f 1'"
        echo "RUNNING:" $cmd
        first_node_ip=$(eval $cmd)  
        echo "FIRST NODE IP:  $first_node_ip"

		echo "##### RUNNING INIT #####"
		cmd="ssh -p $i $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no /opt/couchbase/bin/couchbase-cli cluster-init -c $first_node_ip:8091 --cluster-username=$couchbase_admin_account_name --cluster-password=$couchbase_admin_account_password --cluster-init-ramsize=$cluster_ramsize --services=data,query,index --cluster-index-ramsize=$cluster_index_ramsize"
		echo "RUNNING:" $cmd
		eval $cmd
	else
        #add-cluster on non-first node
        cmd="ssh -p $i $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'ifconfig | grep 10.0.0. | cut -d\":\" -f 2 | cut -d\" \" -f 1'"
        echo "RUNNING:" $cmd
        node_ip=$(eval $cmd)  
        echo "NODE IP: $node_ip"

		echo "##### RUNNING ADD #####"
		cmd="ssh -p $i $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private /opt/couchbase/bin/couchbase-cli server-add -c $first_node_ip:8091 -u $couchbase_admin_account_name -p $couchbase_admin_account_password --server-add=$node_ip:8091 --server-add-username=$couchbase_admin_account_name --server-add-password=$couchbase_admin_account_password --services=data,index,query"
		echo "RUNNING:" $cmd
		eval $cmd
	fi
done

#rebalance cluster
echo "##### RUNNING REBALANCE #####"
cmd="ssh -p 1 $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no /opt/couchbase/bin/couchbase-cli rebalance -c $first_node_ip:8091 -u $couchbase_admin_account_name -p $couchbase_admin_account_password"
echo "RUNNING:" $cmd
eval $cmd

echo "all done."
