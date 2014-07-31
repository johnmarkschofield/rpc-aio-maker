#!/bin/bash

set -e
set -o pipefail
set -x
source cloudenv

scp install_openstack.bash root@$PUBLIC_IP:~
scp cloudenv root@$PUBLIC_IP:~
scp rpc_user_config.yml root@$PUBLIC_IP:~

set +x
echo
echo
echo "First, source cloudenv"
echo "Then ssh to root@$PUBLIC_IP and run /root/install_openstack.bash."
echo
echo
echo "source cloudenv"
echo 'ssh $SRVR'
echo "tmux"
echo 'time /root/install_openstack.bash'
echo
