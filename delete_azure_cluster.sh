#!/bin/sh
account="cb@cihangirbhotmail.onmicrosoft.com"

azure login -u $account

#set mode to asm
azure config mode asm

for ((i=1; i<=8; i++))
do
	echo "Working on deleting instance: $i"
	azure vm delete cbase-$i -q
done
