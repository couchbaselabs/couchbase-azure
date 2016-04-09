#!/bin/sh
download="https://onedrive.live.com/download?resid=EABC62172B7182F3!17813&authkey=!ABcJ7cALjo_KAg0"
binary="couchbase-server-enterprise_4.5.0-2047-ubuntu14.04_amd64.deb"
region="'west US'"
account="cb@cihangirbhotmail.onmicrosoft.com"
auth_cert="/Users/cihan/myCert.pem"
total_nodes=8

echo "DOWNLOAD : " $download

#remove known hosts file if exists.
rm /Users/cihan/.ssh/*

#switch azure mode to asm
azure config mode asm
azure login -u $account


for ((i=1; i<=$total_nodes; i++))
do
	#create vm
	echo "Working on instance: $i"
    cmd="azure vm create -l $region -z Standard_D11 -e $i -n cbase-$i -w cb_private1 -c couchbase-west -t $auth_cert -g azureuser -P -s 3d01005f-455d-4430-b930-8455310e1f65 b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_4-LTS-amd64-server-20160314-en-us-30GB"
    echo "RUNNING:" $cmd 
    eval $cmd
    sleep 120

	#download
	echo "download 4.0"
	cmd="ssh -p $i azureuser@couchbase-west.cloudapp.net -i /Users/cihan/myPrivateKey.key -o StrictHostKeyChecking=no 'sudo wget \"$download\" -O $binary'"
	echo "RUNNING:" $cmd
	eval $cmd

	#install
	echo "install 4.0"
	cmd="ssh -p $i azureuser@couchbase-west.cloudapp.net -i /Users/cihan/myPrivateKey.key -o StrictHostKeyChecking=no 'sudo dpkg -i $binary'"
	echo "RUNNING:" $cmd
	eval $cmd
	sleep 30

	#init-cluster on first node and add-node on rest of the nodes
	if [ $i -eq 1 ]

        #init-cluster on first node and add-node on rest of the nodes
	then 
		first_node_ip=$(ssh -p $i azureuser@couchbase-west.cloudapp.net -i /Users/cihan/myPrivateKey.key -o StrictHostKeyChecking=no 'ifconfig | grep 10.0.0. | cut -d":" -f 2 | cut -d" " -f 1')
		echo "first node IP:  $first_node_ip"

		echo "##### RUNNING INIT #####"
		cmd="ssh -p $i azureuser@couchbase-west.cloudapp.net -i /Users/cihan/myPrivateKey.key -o StrictHostKeyChecking=no /opt/couchbase/bin/couchbase-cli cluster-init -c $first_node_ip:8091 --cluster-username=cb --cluster-password=couchB@SE --cluster-init-ramsize=4000 --services=data,query,index --cluster-index-ramsize=4000"
		echo "RUNNING:" $cmd
		eval $cmd
	else
		node_ip=$(ssh -p $i azureuser@couchbase-west.cloudapp.net -i /Users/cihan/myPrivateKey.key -o StrictHostKeyChecking=no 'ifconfig | grep 10.0.0. | cut -d":" -f 2 | cut -d" " -f 1')
		echo "node IP: $node_ip"

		echo "##### RUNNING ADD #####"
		cmd="ssh -p $i azureuser@couchbase-west.cloudapp.net -i /Users/cihan/myPrivateKey.key /opt/couchbase/bin/couchbase-cli server-add -c $first_node_ip:8091 -u cb -p couchB@SE --server-add=$node_ip:8091 --server-add-username=cb --server-add-password=couchB@SE --services=data,index,query --cluster-index-ramsize=4000"
		echo "RUNNING:" $cmd
		eval $cmd
	fi
done

#rebalance cluster
echo "##### RUNNING REBALANCE #####"
cmd="ssh -p 1 azureuser@couchbase-west.cloudapp.net -i /Users/cihan/myPrivateKey.key -o StrictHostKeyChecking=no /opt/couchbase/bin/couchbase-cli rebalance -c $first_node_ip:8091 -u cb -p couchB@SE"
echo "RUNNING:" $cmd
eval $cmd

echo "all done."
