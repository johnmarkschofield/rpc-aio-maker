#!/bin/bash

set -e
set -o pipefail
set -u
source /root/cloudenv
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
sed -i "s|rackspace_cloud_tenant_id:.*|rackspace_cloud_tenant_id: $OS_TENANT_NAME|g" $USERVARFILE
sed -i "s|rackspace_cloud_username:.*|rackspace_cloud_username: $OS_USERNAME|g" $USERVARFILE
sed -i "s|rackspace_cloud_password:.*|rackspace_cloud_password: $RACKSPACE_LOGIN_PW|g" $USERVARFILE
sed -i "s|rackspace_cloud_api_key:.*|rackspace_cloud_api_key: $OS_PASSWORD|g" $USERVARFILE

sed -i "s|rabbitmq_password:.*|rabbitmq_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|rabbitmq_cookie_token:.*|rabbitmq_cookie_token: `pwgen 32 1`|g" $USERVARFILE

sed -i "s|memcached_encryption_key:.*|memcached_encryption_key: `pwgen 32 1`|g" $USERVARFILE

sed -i "s|container_openstack_password:.*|container_openstack_password: `pwgen 32 1`|g" $USERVARFILE

sed -i "s|mysql_root_password:.*|mysql_root_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|mysql_debian_sys_maint_password:.*|mysql_debian_sys_maint_password: `pwgen 32 1`|g" $USERVARFILE

sed -i "s|keystone_container_mysql_password:.*|keystone_container_mysql_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|keystone_auth_admin_token:.*|keystone_auth_admin_token: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|keystone_auth_admin_password:.*|keystone_auth_admin_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|keystone_service_password:.*|keystone_service_password: `pwgen 32 1`|g" $USERVARFILE

sed -i "s|cinder_container_mysql_password:.*|cinder_container_mysql_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|cinder_service_password:.*|cinder_service_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|cinder_v2_service_password:.*|cinder_v2_service_password: `pwgen 32 1`|g" $USERVARFILE

sed -i "s|glance_default_store:.*|glance_default_store: file|g" $USERVARFILE
sed -i "s|glance_container_mysql_password:.*|glance_container_mysql_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|glance_service_password:.*|glance_service_password: `pwgen 32 1`|g" $USERVARFILE

sed -i "s|heat_stack_domain_admin_password:.*|heat_stack_domain_admin_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|heat_container_mysql_password:.*|heat_container_mysql_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|heat_service_password:.*|heat_service_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|heat_cfn_service_password:.*|heat_cfn_service_password: `pwgen 32 1`|g" $USERVARFILE

sed -i "s|maas_notification_plan:.*|maas_notification_plan: $ADMIN_EMAIL|g" $USERVARFILE
sed -i "s|maas_agent_token:.*|maas_agent_token: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|maas_keystone_password:.*|maas_keystone_password: `pwgen 32 1`|g" $USERVARFILE

sed -i "s|neutron_container_mysql_password:.*|neutron_container_mysql_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|neutron_service_password:.*|neutron_service_password: `pwgen 32 1`|g" $USERVARFILE

sed -i "s|nova_container_mysql_password:.*|nova_container_mysql_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|nova_metadata_proxy_secret:.*|nova_metadata_proxy_secret: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|nova_ec2_service_password:.*|nova_ec2_service_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|nova_service_password:.*|nova_service_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|nova_v3_service_password:.*|nova_v3_service_password: `pwgen 32 1`|g" $USERVARFILE
sed -i "s|nova_s3_service_password:.*|nova_s3_service_password: `pwgen 32 1`|g" $USERVARFILE

sed -i "s|rpc_support_holland_password:.*|rpc_support_holland_password: `pwgen 32 1`|g" $USERVARFILE

# Think this isn't needed.
#grep -q -E "^lb_vip_address" $USERVARFILE || echo -e "\n\nlb_vip_address: 10.51.50.1" >> $USERVARFILE




# Install requirements
pip install -r /opt/ansible-lxc-rpc/requirements.txt

# Set up SSH
rm -f /root/.ssh/id_rsa
rm -f /root/.ssh/id_rsa.pub
ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys


# Run openstack installer
/usr/bin/python /opt/ansible-lxc-rpc/tools/install.py --haproxy --galera --rabbit --retries=3
