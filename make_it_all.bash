#!/bin/bash

set -e

source cloudenv
./instance_provision.bash
source cloudenv
./config_host_packages.bash
source cloudenv
./config_host_drives.bash
source cloudenv
./config_host_network.bash
source cloudenv

./prepare_for_openstack.bash

echo
echo
echo "Done with make_it_all.bash"