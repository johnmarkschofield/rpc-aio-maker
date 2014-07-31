#!/bin/bash

set -e
set -o pipefail
set -x
source /root/cloudenv

RETRIES=3

run_playbook()
{
	cd /opt/ansible-lxc-rpc/rpc_deployment
	ATTEMPT=1
	VERBOSE=""
	set +e
	while ! ansible-playbook $VERBOSE -e @vars/user_variables.yml $1 ; do 
		if [ $ATTEMPT -ge $RETRIES ]; then
			exit 1
		fi
		ATTEMPT=$((ATTEMPT+1))
		sleep 90
		VERBOSE=-vvv
	done
	set -e
}




rm -rf /opt/ansible-lxc-rpc
mkdir -p /opt
git clone $GIT_URL -b $GIT_BRANCH /opt/ansible-lxc-rpc

pip install --upgrade -r /opt/ansible-lxc-rpc/requirements.txt

cp -R /opt/ansible-lxc-rpc/etc/rpc_deploy /etc/rpc_deploy

cp /root/rpc_user_config.yml /etc/rpc_deploy/

rm -f /root/.ssh/id_rsa
rm -rf /root/.ssh/id_rsa.pub
ssh-keygen -t rsa -f /root/.ssh/id_rsa -N ''

cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# Not necessary because d34dh0r53 made these parameters auto-configuring
# sed -i 's/^elasticsearch_heap:.*/elasticsearch_heap: 1g/g' /opt/ansible-lxc-rpc/rpc_deployment/inventory/group_vars/elasticsearch.yml
# sed -i 's/^logstash_heap:.*/logstash_heap: 1g/g' /opt/ansible-lxc-rpc/rpc_deployment/inventory/group_vars/logstash.yml


sed -i "s/^lb_vip_address:.*/lb_vip_address: 10.51.50.1/" /opt/ansible-lxc-rpc/rpc_deployment/vars/user_variables.yml

run_playbook playbooks/setup/host-setup.yml
run_playbook playbooks/setup/build-containers.yml
run_playbook playbooks/setup/restart-containers.yml
run_playbook playbooks/setup/it-puts-common-bits-on-disk.yml

run_playbook playbooks/infrastructure/memcached.yml
run_playbook playbooks/infrastructure/galera-install.yml
run_playbook playbooks/infrastructure/rabbit-install.yml
run_playbook playbooks/infrastructure/rsyslog-install.yml
run_playbook playbooks/infrastructure/elasticsearch-install.yml
run_playbook playbooks/infrastructure/logstash-install.yml
run_playbook playbooks/infrastructure/kibana-install.yml
run_playbook playbooks/infrastructure/rsyslog-config.yml
run_playbook playbooks/infrastructure/es2unix-install.yml
run_playbook playbooks/infrastructure/haproxy-install.yml

run_playbook playbooks/openstack/utility.yml
run_playbook playbooks/openstack/it-puts-openstack-bits-on-disk.yml
run_playbook playbooks/openstack/keystone.yml
run_playbook playbooks/openstack/keystone-add-all-services.yml
run_playbook playbooks/openstack/keystone-add-users.yml
run_playbook playbooks/openstack/glance-all.yml
run_playbook playbooks/openstack/heat-all.yml
run_playbook playbooks/openstack/nova-all.yml
run_playbook playbooks/openstack/neutron-all.yml
run_playbook playbooks/openstack/cinder-all.yml
run_playbook playbooks/openstack/horizon.yml

echo "All DONE!"