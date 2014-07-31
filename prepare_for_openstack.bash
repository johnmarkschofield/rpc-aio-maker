#!/bin/bash

set -e
set -o pipefail
set -x
source cloudenv

scp install_openstack.bash root@$PUBLIC_IP:~
scp cloudenv root@$PUBLIC_IP:~
scp rpc_user_config.yml root@$PUBLIC_IP:~

echo
echo
echo "First, source cloudenv"
echo "Then ssh to root@$PUBLIC_IP and run /root/install_openstack.bash."
echo
echo
echo "since the ansible stuff isn't 100% deterministic, this is a good set of commands to run:"
echo
echo "source cloudenv"
echo "ssh $PUBLIC_IP"
echo "tmux"
echo '/root/install_openstack.bash || /root/install_openstack.bash || /root/install_openstack.bash || /root/install_openstack.bash'
echo
