#!/bin/bash

set -e
set -o pipefail
set -u
source cloudenv
set -x


scp install_openstack.bash root@$PUBLIC_IP:~
scp cloudenv root@$PUBLIC_IP:~
scp rpc_user_config.yml root@$PUBLIC_IP:~

set +x
echo 
echo 
echo "Now scp to root@$PUBLIC_IP and run /root/install_openstack.bash:"
echo
echo "source cloudenv"
echo 'ssh $PUBLIC_IP'
echo "tmux"
echo "time /bin/bash /root/install_openstack.bash"
