#!/bin/bash

set -e
set -o pipefail
set -x

# Ubuntu 14.04 LTS (Trusty Tahr) (PVHVM)

nova boot \
	--flavor performance1-8 \
	--image 255df5fb-e3d4-45a3-9a07-c976debf7c14 \
	--nic net-id=$MGMT_NETWORK_ID \
	--key-name $KEYPAIR_NAME \
	--poll \
	$SERVERNAME
	

export PUBLIC_IP=`nova show $SERVERNAME | grep "public network" | awk '{print $6}'`
sed -i .bak "s|export PUBLIC_IP=.*|export PUBLIC_IP=$PUBLIC_IP|g" ./cloudenv
rm cloudenv.bak

# We do an SSD volume for greater speed. Omit the --volume-type line if you want SATA.
nova volume-create 250 \
	--display-name $LXC_VOLUME_NAME \
	--volume-type 8a4e0d56-b904-44f7-b4bc-8b065729136b

export LXC_VOLUME_ID=`nova volume-show $LXC_VOLUME_NAME | grep  -E '\| id\W*\|' | awk '{print $4}'`
sed -i .bak "s|export LXC_VOLUME_ID=.*|export LXC_VOLUME_ID=$LXC_VOLUME_ID|g" ./cloudenv

nova volume-attach $SERVERNAME $LXC_VOLUME_ID

echo
echo
echo "Don't forget to source cloudenv now."