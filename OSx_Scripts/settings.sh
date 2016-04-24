#!/bin/sh

##couchbase settings
#total nodes in cluster
couchbase_total_nodes=3
#ubuntu 14 image for couchbase server. version can be 4.0 or later
couchbase_download="http://packages.couchbase.com/releases/4.1.0/couchbase-server-enterprise_4.1.0-ubuntu14.04_amd64.deb"
couchbase_binary="couchbase-server-enterprise_4.1.0-ubuntu14.04_amd64.deb"
#TODO: change this username
couchbase_admin_account_name="cb_dbadmin"
#TODO: change this password
couchbase_admin_account_password="couchB@SE123"
#couchbase services on nodes
couchbase_node_services="data,query,index"
#ram configurations
couchbase_cluster_index_ramsize=1000
couchbase_cluster_ramsize=1000

##azure settings
#TODO: use "azure login -u account" +  "azure account show" to get  account and subscriptionid
azure_account="your_account@your_domain.onmicrosoft.com"
subscription_id="00000000-0000-0000-0000-000000000000"
#TODO: certs for ssh. use ssh-keygen to generate the keys - public and private
couchbase_vm_auth_cert_public="~/your_public_key.pub"
couchbase_vm_auth_cert_private="~/your_private_key.key"
#prefix to use for the VM name for all nodes 
vm_name_prefix="cb_"
#vnet name to keeps azure vms in the same subnet 
vnet_name="cb-vnet1" 
#azure service name for all nodes
service_name="couchbase-service"
#region where to provision all nodes
region="'west US'"


##jumpbox settings
jumpbox_image_name="a699494373c04fc0bc8f2bb1389d6106__Windows-Server-2012-Datacenter-20160329-en.us-127GB.vhd"
#jumpbox vm sku to use. 
jumpbox_vm_sku="Standard_D2"
jumpbox_admin_account_name="cb_vmadmin"
jumpbox_admin_account_password="couchB@SE123"

##cluster settings
#ubuntu OS image to use on azure
couchbase_vm_image_name="b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_4-LTS-amd64-server-20160314-en-us-30GB"
#cluster vm sku to use. Standard_D2 can be used as the minimum HW. 
couchbase_vm_sku="Standard_D2"
#couchbase cluster vm admin account name
couchbase_vm_admin_account_name="cb_vmadmin"

#misc settings
remove_known_hosts=0
