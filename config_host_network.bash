#!/bin/bash

set -e
set -o pipefail
set -u
source cloudenv
set -x

ssh root@$PUBLIC_IP cp /etc/network/interfaces /etc/network/interfaces.original.`date +%Y-%m-%d_%H-%M-%S-%N`

scp interfaces_mungerator.py root@$PUBLIC_IP:~
scp cloudenv root@$PUBLIC_IP:~
ssh root@$PUBLIC_IP "source /root/cloudenv ; python /root/interfaces_mungerator.py"

ssh root@$PUBLIC_IP reboot
set +e
while ! ssh root@$PUBLIC_IP ls ; do sleep 5 ; done
set -e
