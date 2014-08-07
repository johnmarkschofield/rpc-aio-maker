#!/bin/bash

set -e
set -o pipefail
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
	--flavor performance1-8 \
	--image $BOOTIMAGE \
    --nic net-id=$MGMT_NETWORK_ID \
    --nic net-id=$VMNET_NETWORK_ID \
	--key-name $KEYPAIR_NAME \
	--poll \
	$SERVERNAME
	

export PUBLIC_IP=`nova show $SERVERNAME | grep "public network" | grep -oh -E "\b(?:\d{1,3}\.){3}\d{1,3}\b"`
sed -i .bak "s|export PUBLIC_IP=.*|export PUBLIC_IP=$PUBLIC_IP|g" ./cloudenv
rm cloudenv.bak

nova volume-create $EXTERNAL_VOLUME_GB \
	--display-name $LXC_VOLUME_NAME \
    --volume-type $LXC_VOLUME_TYPE

export LXC_VOLUME_ID=`nova volume-show $LXC_VOLUME_NAME | grep  -E '\| id\W*\|' | awk '{print $4}'`
sed -i .bak "s|export LXC_VOLUME_ID=.*|export LXC_VOLUME_ID=$LXC_VOLUME_ID|g" ./cloudenv
rm cloudenv.bak

nova volume-attach $SERVERNAME $LXC_VOLUME_ID

echo
echo
echo "Don't forget to source cloudenv now."