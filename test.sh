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

cmd="ssh -p 1 cb_vmadmin@couchbase-service.cloudapp.net -i $auth_cert_private -o StrictHostKeyChecking=no 'ifconfig | grep 10.0.0. | cut -d\":\" -f 2 | cut -d\" \" -f 1'"
echo "RUNNING:" $cmd
first_node_ip=$(eval $cmd)  
echo "FIRST NODE IP:  $first_node_ip"

