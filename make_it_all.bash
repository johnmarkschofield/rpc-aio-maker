#!/bin/bash

set -e
set -o pipefail
set -x

./instance_provision.bash
./config_host_packages.bash
./config_host_drives.bash
./config_host_network.bash
./prepare_for_openstack.bash

echo
echo
echo "Done with make_it_all.bash"