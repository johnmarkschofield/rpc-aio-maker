
set -e
set -o pipefail
set -x
source /root/cloudenv

USERVARFILE=/opt/ansible-lxc-rpc/rpc_deployment/vars/user_variables.yml


# Set up Repo
rm -rf /opt/ansible-lxc-rpc
mkdir -p /opt
git clone $GIT_URL -b $GIT_BRANCH /opt/ansible-lxc-rpc

# Set up config
cp -R /opt/ansible-lxc-rpc/etc/rpc_deploy /etc/rpc_deploy
cp /root/rpc_user_config.yml /etc/rpc_deploy/
grep -q -E "^lb_vip_address" $USERVARFILE || echo -e "\n\nlb_vip_address: 10.51.50.1" >> $USERVARFILE
# Not needed not using glance
#sed -i "s|glance_swift_store_auth_address:.*|glance_swift_store_auth_address: https://{{ lb_vip_address }}/v2.0|g" $USERVARFILE
sed -i "s|glance_default_store:.*|glance_default_store: file|g" $USERVARFILE

# Install requirements
pip install -r /opt/ansible-lxc-rpc/requirements.txt

# Set up SSH
rm -f /root/.ssh/id_rsa
rm -f /root/.ssh/id_rsa.pub
ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys


# Run openstack installer
/usr/bin/python /opt/ansible-lxc-rpc/tools/install.py --no-haproxy --galera --rabbit --retries=3
