#!/bin/bash

set -e
set -o pipefail
set -u
source cloudenv
set -x

USERVARFILE=/etc/rpc_deploy/user_variables.yml


# Set up Repo
rm -rf /opt/ansible-lxc-rpc
mkdir -p /opt
ssh -o StrictHostKeyChecking=no git@github.com || true
git clone $GIT_URL -b $GIT_BRANCH /opt/ansible-lxc-rpc

# Set up config dir
cp -R /opt/ansible-lxc-rpc/etc/rpc_deploy /etc/rpc_deploy
cp /root/rpc_user_config.yml /etc/rpc_deploy/

# Change user_variables.yml
sed -i "s|rackspace_cloud_auth_url:.*|rackspace_cloud_auth_url: $OS_AUTH_URL|g" $USERVARFILE
sed -i "s|rackspace_cloud_tenant_id:.*|rackspace_cloud_tenant_id: $OS_TENANT_NAME"
sed -i "s|glance_default_store:.*|glance_default_store: file|g" $USERVARFILE


grep -q -E "^lb_vip_address" $USERVARFILE || echo -e "\n\nlb_vip_address: 10.51.50.1" >> $USERVARFILE




# Install requirements
pip install -r /opt/ansible-lxc-rpc/requirements.txt

# Set up SSH
rm -f /root/.ssh/id_rsa
rm -f /root/.ssh/id_rsa.pub
ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys


# Run openstack installer
/usr/bin/python /opt/ansible-lxc-rpc/tools/install.py --haproxy --galera --rabbit --retries=3
