# couchbase-azure simple & automated setup
Simple automated setup a couchbase server cluster on azure. Ideal for build up and teardown of test environments or functional tests. Works with couchbase server v4.0 or later. Simply point to the build you like to use and provide azure account details in the settings.sh file, followed by create_azure_cluster. use delete_azure_cluster to destroy the cluster.
_Limitations_: There are a few limitations with the scripts. 
- _ephemeral drives_: scripts are mainly tuned for dev/test systems and not for production deployment. for production deployment, couchbase server requires mounted drives that can live through node restarts etc.
- _xdcr (cross data-center replication)_: you can use the scripts to deploy 2 clusters to 2 seperate regions. however the scripts are not design to make xdcr working with couchbase server. there are a few other tricks required to do that.
- _app deployment_: i typically use the jumpbox for test runs which is created in the same subnet. 

##OSx Scripts: 
OSx script for setting up a multi node Couchbase Server cluster on Azure VMs.

###Prerequisites
install_prereqs.sh: Install required dependencies like node and azure-cli. Run this before your first run.

###Settings
settings.sh: setting file for the automated cluster setup. seach for and modify the variables marked with text "TODO" in the setting file before running create_ and delete_ scripts. the scripts will fail if you do not review and assign the required values for these variables at minimum.

**Couchbase Server Settings:**
````
    couchbase_total_nodes: set the number of nodes in the cluster.
    
    couchbase_download: link to the download URL for ubuntu 14.04 version couchbase server. 
    
    couchbase_binary: name of the binary for couchbase. used to help rename the downloaded 
    binary. 
    
    couchbase_admin_account_name: database administration account for Couchbase Server cluster.
    TODO: change this value before use. 
    
    couchbase_admin_account_password: database administration password for Couchbase Server 
    cluster. TODO: change this value before use. 
    
    couchbase_node_services: services to enable on all nodes (data, index, query etc.). All 
    deployments do the simpler homogenious deployment with the same services on all nodes. 
    "data" service is always required and other services are optional. 
    
    cluster_ramsize: initial data service RAM quota per node. can be changed under settings tab 
    in the couchbase server web console. 
    
    cluster_index_ramsize: initial index service RAM quota per node. used if index service is 
    enabled. can be changed under settings tab in the couchbase server web console. 
````

**Azure Config Settings:**
````
    azure_account: your fully qualified azure account. account you use to login to portal. best 
    practice is to use a delegate admin account to protect against account compromise. TODO: 
    change this value before use.
    
    azure_subscription_id: azure subscription id for the azure account. if you don't know your 
    subscription id, use "azure login -u account" +  "azure account show" to get  account and 
    subscriptionid. TODO: change this value before use.
    
    auth_cert_public: auth public key used for provisioning the couchbase server nodes on 
    ubuntu. TODO: change this value before use. use ssh-keygen to generate the keys - public 
    and private keys. 
    
    auth_cert_private: auth private key used for logging in with ssh without passwords.  
    
    region: azure region for the setup. default is "us-west". TODO: change this value before 
    use. use ssh-keygen to generate the keys - public and private keys. 
    
    vm_name_prefix: prefix to the vm names created by the script. it is important to pick a 
    unique prefix name that does not match any of the other VM names in your subscription. 
    delete_azure_cluster script deletes nodes matching this prefix. 
    
    vnet_name: virtual network name for the couchbase server subnet. vnet setup is done for 
    network communication efficiency with the couchbase server cluster. virtual network (vnets) 
    enable private 10.0.*.* IPs in a single subnet for all VMs including the jumpbox.
    
    service_name: service name ensure ssh and jumpbox RDP addresses can be under a single cloud 
    service name with different port names. jumpbox gets 3389 rdp port and all couchbase server 
    nodes gets port 1..N for ssh. for example:
        RDP into the jumpbox: service_name.cloudapp.net:3398
        SSH into the first node: ssh -p 1 cb_vmadmin@service_name.cloudapp.net
````

**Azure Jumpbox VM Config Settings:**
````
    disable jumpbox: 1 to diable jumpbox. jumpbox is provisioned for security reasons. Without 
    a node within the same vnet, you end up exposing your database directly to the internet, 
    opening Web Console (8091) and other couchbase server ports to the public internet. 
    
    jumpbox_image_name: image to use for the jumpbox. using windows server by default
    
    jumpbox_vm_sku: vm sku to use on azure for jumpbox vm 
    
    jumpbox_vm_admin_account_name: account name for jumpbox vm admin.
    
    jumpbox_vm_admin_account_password: account password for jumpbox vm admin.
````

**Azure Couchbase Cluster Nodes VM Config Settings:**
````
    couchbase_vm_image_name: ubuntu OS image to use on azure for couchbase server cluster nodes.
    
    couchbase_vm_sku: vm sku to use on azure for couchbase server cluster node vms.
    
    couchbase_vm_admin_account_name: account name for couchbase cluster node vm admin. certs 
    are used for password-less logins.
````
**Misc Config**
````
    remove_known_hosts: this will enable removing the .ssh/known_hosts file under MacOS. The 
    file gets in the way of reprovisioning the same node names for the cluster.
    
    enable_fast_delete: enable fast delete will supress confirmation on deletes of each VM. do 
    this only if you are certain delete will not harm your existing VMs and you have tried the 
    script multiple times.
````


###Create Azure Cluster
create_azure_cluster.sh: Main script to create the VMs, download and install Couchbase Server and set up the cluster with a final rebalance. Will require you to login to your Azure account. 
Settings will also, by default, allow a Windows Server jumpbox to be configured in the same vnet (see the vnet_name. setting above for details on vnets). The jumpbox ensures you don't expose your Couchbase Server directly to the internet. You can disable the jumpbox if you are using an existing vnet where you already have a browser to administer couchbase server, Or if you are simply looking to administer through the couchbase-cli commandline interface. 

###Delete Azure Cluster
delete_azure_cluster.sh: used to clean up the jumpbox, cluster and vms. Will require you to login to your Azure account. cleanup looks for the vm_name_prefix set in the settings file to match and delete VMs. To ensure it does not do accidental deletes, enable_fast_delete is off by default. You can enable_fast_delete, however make sure your prefix is unique and does not match your existing VMs in your subscription. 
