# couchbase-azure
setup a couchbase server cluster on azure with couchbase server v4.0 or later. 

##OSx Scripts: 
OSx script for setting up a multi node Couchbase Server cluster on Azure VMs.

###install_prereqs.sh
install required dependencies like node and azure-cli.

###create_azure_cluster .sh
main script to create the VMs, download and install Couchbase Server and set up the couchbase server cluster with a final rebalance.

###delete_azure_cluster .sh
used to clean up the cluster and vms.

###settings.sh
setting file for the automated setup.
Couchbase Server Settings:
    couchbase_download: link to the download URL.
    couchbase_binary: name of the binary
    couchbase_admin_account_name: database administration account for Couchbase Server cluster.
    couchbase_admin_account_password: database administration password for Couchbase Server cluster.
    cluster_index_ramsize: initial index RAM quota
    cluster_ramsize: initial data RAM quota
    total_nodes: number of nodes to set up.

**Azure VM Config Settings**
region: region for the setup. default is us-west
image_name: VM image to use. default is classic ubuntu 14.04
account: your azure account
subscription_id: azure subscription id. if you don't know your subscription id, use "azure login -u account" +  "azure account show" to get  account and subscriptionid 
auth_cert_public: auth public key. use ssh-keygen to generate the keys - public and private keys
auth_cert_private: auth private key. 
vm_name_prefix: vm name prefix
vm_admin_account_name: vm administrator account name
vnet_name: virtual network name for the couchbase server subnmet. virtual network allows private IPs in a single to be used for efficient network communication. 

- Misc Setting
remove_known_hosts: 1 to remove ~/.ssh/known_hosts file. script uses ssh to connect to newly provisioned nodes. known hosts file can throw warnings and errors under repeated runs. remove known_hosts to prevent warnings and errors when connecting to vms.
