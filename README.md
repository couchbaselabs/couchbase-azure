# couchbase-azure
Simple automated setup a couchbase server cluster on azure. Ideal for build up and teardown of test environments or functional tests. Works with couchbase server v4.0 or later. Simply point to the build you like to use and provide azure account details in the settings.sh file, followed by create_azure_cluster. use delete_azure_cluster to destroy the cluster.

##OSx Scripts: 
OSx script for setting up a multi node Couchbase Server cluster on Azure VMs.

###Prerequisites
install_prereqs.sh: Install required dependencies like node and azure-cli. Run this before your first run.

###Settings
settings.sh: setting file for the automated cluster setup. Modify to use your desired azure and couchbase settings details before running create_ and delete_ scripts.

**Couchbase Server Settings:**
````
    couchbase_download: link to the download URL.
    couchbase_binary: name of the binary
    couchbase_admin_account_name: database administration account for Couchbase Server cluster.
    couchbase_admin_account_password: database administration password for Couchbase Server cluster.
    cluster_index_ramsize: initial index RAM quota
    cluster_ramsize: initial data RAM quota
    couchbase_total_nodes: number of nodes to set up.
````

**Azure VM Config Settings:**
````
    region: region for the setup. default is us-west
    couchbase_vm_image_name: VM image to use. default is classic ubuntu 14.04
    account: your azure account
    subscription_id: azure subscription id. if you don't know your subscription id, use "azure login -u account" +  
    "azure account show" to get  account and subscriptionid 
    auth_cert_public: auth public key. use ssh-keygen to generate the keys - public and private keys
    auth_cert_private: auth private key. 
    vm_name_prefix: vm name prefix
    vm_admin_account_name: vm administrator account name
    vnet_name: virtual network name for the couchbase server subnet. vnet setup is done for network communication 
    efficiency. virtual network gets  private IPs in a single subnet for all nodes. 
````
###Create Azure Cluster
create_azure_cluster.sh: Main script to create the VMs, download and install Couchbase Server and set up the cluster with a final rebalance. Will require you to login to your Azure account before any changes to the azure env is started. 

###Delete Azure Cluster
delete_azure_cluster.sh: used to clean up the cluster and vms. Will require you to login to your Azure account before any changes to the azure env is started.
