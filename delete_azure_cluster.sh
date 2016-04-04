#!/bin/sh

azure login -u cb@cihangirbhotmail.onmicrosoft.com
azure config mode asm
for ((i=1; i<=8; i++))
do
	echo "Working on deleting instance: $i"
	azure vm delete cbase-$i -q
done
