#!/bin/sh
account="cb@cihangirbhotmail.onmicrosoft.com"
vnet_name="cb_private1"
total_nodes=8

#login
azure login -u $account
#set mode to asm
azure config mode asm

for ((i=1; i<=$total_nodes; i++))
do
	echo "Working on deleting instance: $i"
	azure vm delete cbase-$i -q
done

#delete the vnet
azure network vnet delete $vnet_name -q