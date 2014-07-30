#!/bin/bash

set -e
set -o pipefail
set -x

ssh root@$PUBLIC_IP cp /etc/network/interfaces /etc/network/interfaces.original

ssh root@$PUBLIC_IP "sed -i '/# Label '$MGMT_NETWORK_NAME'/,\$d' /etc/network/interfaces"
ssh root@$PUBLIC_IP "echo >> /etc/network/interfaces"
ssh root@$PUBLIC_IP "echo \"# Label $MGMT_NETWORK_NAME\" >> /etc/network/interfaces"


scp interfaces_fragment root@$PUBLIC_IP:~
ssh root@$PUBLIC_IP "cat /root/interfaces_fragment >> /etc/network/interfaces"
ssh root@$PUBLIC_IP rm /root/interfaces_fragment

ssh root@$PUBLIC_IP reboot
set +e
while ! ssh root@$PUBLIC_IP ls ; do sleep 5 ; done
set -e
