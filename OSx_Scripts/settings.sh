#!/bin/sh

#couchbase settings
couchbase_download="https://onedrive.live.com/download?resid=EABC62172B7182F3!17823&authkey=!AP4fFpc2gqjXFoo"
couchbase_binary="couchbase-server-enterprise_4.5.0-2151-ubuntu14.04_amd64.deb"
couchbase_admin_account_name="cb_dbadmin"
couchbase_admin_account_password="couchB@SE"
cluster_index_ramsize=4000
cluster_ramsize=4000
total_nodes=8

#azure settings

region="'west US'"
image_name="b39f27a8b8c64d52b05eac6a62ebad85__Ubuntu-14_04_4-LTS-amd64-server-20160314-en-us-30GB"
account="cb@cihangirbhotmail.onmicrosoft.com"
#use "azure login -u account" +  "azure account show" to get  account and subscriptionid
subscription_id="3d01005f-455d-4430-b930-8455310e1f65"
#use ssh-keygen to generate the keys - public and private
auth_cert_public="~/test.pub"
auth_cert_private="~/test.key"
vm_name_prefix="cbase"
vm_admin_account_name="cb_vmadmin"
#vnet keeps azure vms in the same subnet
vnet_name="cb_private1"

#misc settings
remove_known_hosts=1