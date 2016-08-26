#!/bin/bash

file=nodes.txt
slot=0

printf "\nLocating file containing list of nodes...\n\n"
sleep 2

if [ ! -f $file ]; then
	printf "\nThe file specified to provide the node names\n"
	printf "does not exist in this directory.\n\n"
	exit
fi

printf "\nPreparing to delete old clients and nodes from Chef server...\n\n"
sleep 2

printf "Please ignore any error messages at this point\n"
printf "(They are normal if the node/client trying to be deleted\n"
printf "does not exist on the server)\n\n"
sleep 3

while read line; do
	yes | knife node delete $line
	status_node=$?
		if [ $status_node -ne 0 ]; then
			faildel_nodes[slot]=$line
			((slot++))
		fi
	yes | knife client delete $line
	status_client=$?
		if [ $status_client -ne 0 ]; then
			faildel_clients[slot]=$line
			((slot++))
		fi
done < $file

printf "\nDeletion of client and nodes from Chef server complete.\n\n"

if [ ${#faildel_nodes[@]} -gt 0 ]; then
	printf "The following nodes could not be deleted\n"
	printf "(Possibly because they do not exist in the first place): \n"
	for i in ${faildel_nodes[@]}; do
		echo $i
	done
fi

if [ ${#faildel_clients[@]} -gt 0 ]; then
	printf "\nThe following clients could not be deleted:\n"
	printf "(Possibly because they do not exist in the first place): \n"
	for i in ${faildel_clients[@]}; do
		echo $i
	done
fi
