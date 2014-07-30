#!/bin/bash

set -e
set -o pipefail
set -x

scp install_openstack.bash root@$PUBLIC_IP:~
scp rpc_user_config.yml root@$PUBLIC_IP:~
scp user_variables.yml root@$PUBLIC_IP:~

echo
echo
echo "First, source cloudenv"
echo "Then ssh to root@$PUBLIC_IP and run /root/install_openstack.bash."