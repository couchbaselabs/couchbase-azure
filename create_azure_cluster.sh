#!/bin/sh
download="https://onedrive.live.com/download?resid=EABC62172B7182F3!17813&authkey=!ABcJ7cALjo_KAg0"
binary="couchbase-server-enterprise_4.5.0-2047-ubuntu14.04_amd64.deb"
region="'west US'"
image_name="b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_4-LTS-amd64-server-20160314-en-us-30GB"
account="cb@cihangirbhotmail.onmicrosoft.com"
subscription_id="3d01005f-455d-4430-b930-8455310e1f65"
auth_cert_public="/Users/cihan/test.pub"
auth_cert_private="/Users/cihan/test"
vm_name_prefix="cbase"
vm_admin_account_name="cb_admin"
couchbase_admin_account_name="cb"
couchbase_admin_account_password="couchB@SE"
vnet_name="cb_private1"
total_nodes=8

echo "DOWNLOAD : " $download

#may need to remove known hosts file if exists.
#rm /Users/user_name/.ssh/known_hosts

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
	echo "download 4.0"
	cmd="ssh -p $i $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'sudo wget \"$download\" -O $binary'"
	echo "RUNNING:" $cmd
	eval $cmd

	#install
	echo "install 4.0"
	cmd="ssh -p $i $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'sudo dpkg -i $binary'"
	echo "RUNNING:" $cmd
	eval $cmd
	sleep 30

	#init-cluster on first node and add-node on rest of the nodes
	if [ $i -eq 1 ]

        #init-cluster on first node and add-node on rest of the nodes
	then 
		first_node_ip=$(ssh -p $i $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'ifconfig | grep 10.0.0. | cut -d":" -f 2 | cut -d" " -f 1')
		echo "first node IP:  $first_node_ip"

		echo "##### RUNNING INIT #####"
		cmd="ssh -p $i $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no /opt/couchbase/bin/couchbase-cli cluster-init -c $first_node_ip:8091 --cluster-username=$couchbase_admin_account_name --cluster-password=$couchbase_admin_account_password --cluster-init-ramsize=4000 --services=data,query,index --cluster-index-ramsize=4000"
		echo "RUNNING:" $cmd
		eval $cmd
	else
		node_ip=$(ssh -p $i $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'ifconfig | grep 10.0.0. | cut -d":" -f 2 | cut -d" " -f 1')
		echo "node IP: $node_ip"

		echo "##### RUNNING ADD #####"
		cmd="ssh -p $i $vm_admin_account_name@couchbase-service.cloudapp.net -i $auth_cert_private /opt/couchbase/bin/couchbase-cli server-add -c $first_node_ip:8091 -u $couchbase_admin_account_name -p $couchbase_admin_account_password --server-add=$node_ip:8091 --server-add-username=$couchbase_admin_account_name --server-add-password=$couchbase_admin_account_password --services=data,index,query --cluster-index-ramsize=4000"
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
