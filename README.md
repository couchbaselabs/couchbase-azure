# couchbase-azure
setup a couchbase server cluster on azure with couchbase server v4.0 or later. 
OSx Scripts: OSx script with control parameters at the top.

#create_azure_cluster .sh
used to create the VMs, download and install couchbase server and set up the couchbase server cluster.
download: the link to the Couchbase Server v4 binary to download 
binary: name of the binary file to use. for example: couchbase-server-enterprise_4.1.0-5005-ubuntu14.04_amd64.deb"
region: azure region to use for the deployment
account: azure account to use for the deployment
auth_cert: cert to use for the VMs
total_nodes: number of total nodes

#delete_azure_cluster .sh
used to clean up the cluster and vms.
