#!/bin/bash

set -e
set -o pipefail
set -u
source cloudenv
set -x


# Create networks
nova network-create $MGMT_NETWORK_NAME 10.51.50.0/24
export MGMT_NETWORK_ID=`nova network-list | grep $MGMT_NETWORK_NAME | awk '{print $2}'`
sed -i .bak "s|export MGMT_NETWORK_ID=.*|export MGMT_NETWORK_ID=$MGMT_NETWORK_ID|g" ./cloudenv
rm cloudenv.bak

nova network-create $VMNET_NETWORK_NAME 192.168.20.0/24
export VMNET_NETWORK_ID=`nova network-list | grep $VMNET_NETWORK_NAME | awk '{print $2}'`
sed -i .bak "s|export VMNET_NETWORK_ID=.*|export VMNET_NETWORK_ID=$VMNET_NETWORK_ID|g" ./cloudenv
rm cloudenv.bak


nova boot \
	--flavor $HOST_FLAVOR \
	--image $BOOTIMAGE \
    --nic net-id=$MGMT_NETWORK_ID \
    --nic net-id=$VMNET_NETWORK_ID \
	--key-name $KEYPAIR_NAME \
	--poll \
	$SERVERNAME
	

export PUBLIC_IP=`nova show $SERVERNAME | grep "public network" | grep -oh -E "\b(?:\d{1,3}\.){3}\d{1,3}\b"`
sed -i .bak "s|export PUBLIC_IP=.*|export PUBLIC_IP=$PUBLIC_IP|g" ./cloudenv
rm cloudenv.bak

nova volume-create $LVM_VOLUME_GB \
	--display-name $LVM_VOLUME_NAME \
    --volume-type $LVM_VOLUME_TYPE

export LVM_VOLUME_ID=`nova volume-show $LVM_VOLUME_NAME | grep  -E '\| id\W*\|' | awk '{print $4}'`
sed -i .bak "s|export LVM_VOLUME_ID=.*|export LVM_VOLUME_ID=$LVM_VOLUME_ID|g" ./cloudenv
rm cloudenv.bak

nova volume-attach $SERVERNAME $LVM_VOLUME_ID
