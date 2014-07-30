#!/bin/bash

set -e
set -o pipefail
set -x


rm -rf /opt/ansible-lxc-rpc
git clone git@github.com:rcbops/ansible-lxc-rpc.git /opt/ansible-lxc-rpc

pip install --upgrade -r /opt/ansible-lxc-rpc/requirements.txt

rm -rf /etc/rpc_deploy
cp -R /opt/ansible-lxc-rpc/etc/rpc_deploy /etc/rpc_deploy

cp /root/rpc_user_config.yml /etc/rpc_deploy/

cp /root/user_variables.yml /opt/ansible-lxc-rpc/rpc_deployment/vars/

ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

cd /opt/ansible-lxc-rpc/rpc_deployment

sed -i 's/^elasticsearch_heap:.*/elasticsearch_heap: 1g/g' /opt/ansible-lxc-rpc/rpc_deployment/inventory/group_vars/elasticsearch.yml
sed -i 's/^logstash_heap:.*/logstash_heap: 1g/g' /opt/ansible-lxc-rpc/rpc_deployment/inventory/group_vars/logstash.yml


ansible-playbook -e @vars/user_variables.yml playbooks/setup/all-the-setup-things.yml
ansible-playbook -e @vars/user_variables.yml playbooks/infrastructure/all-the-infrastructure-things.yml
ansible-playbook -e @vars/user_variables.yml playbooks/openstack/all-the-openstack-things.yml
