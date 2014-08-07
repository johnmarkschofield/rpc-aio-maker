#!/bin/bash

set -e
set -o pipefail
set -x

./provision_instance.bash
./config_host_packages.bash
./config_host_drives.bash
./config_host_network.bash
./prepare_for_openstack.bash

