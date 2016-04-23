#!/bin/sh

#couchbase settings
couchbase_download="http://packages.couchbase.com/releases/4.1.0/couchbase-server-enterprise_4.1.0-ubuntu14.04_amd64.deb"
couchbase_binary="couchbase-server-enterprise_4.1.0-ubuntu14.04_amd64.deb"
couchbase_admin_account_name="cb_dbadmin"
couchbase_admin_account_password="couchB@SE"
node_services="data,query,index"
cluster_index_ramsize=1000
cluster_ramsize=1000
total_nodes=4

#azure settings
region="'west US'"
image_name="b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_4-LTS-amd64-server-20160314-en-us-30GB"
#use "azure login -u account" +  "azure account show" to get  account and subscriptionid
azure_account="your_account@your_domain.onmicrosoft.com"
subscription_id="00000000-0000-0000-0000-000000000000"
#use ssh-keygen to generate the keys - public and private
auth_cert_public="~/your_public_key.pub"
auth_cert_private="~/your_private_key.key"
vm_name_prefix="cb_"
vm_admin_account_name="cb_vmadmin"
#vnet keeps azure vms in the same subnet
vnet_name="cb_private1"

#misc settings
remove_known_hosts=1