#!/bin/bash

set -e
set -o pipefail
set -x
source cloudenv

ssh -o StrictHostKeyChecking=no root@$PUBLIC_IP "apt-get update"
ssh root@$PUBLIC_IP "DEBIAN_FRONTEND=noninteractive apt-get install -q -y update-notifier-common"
ssh root@$PUBLIC_IP "DEBIAN_FRONTEND=noninteractive apt-get -q -y dist-upgrade"
ssh root@$PUBLIC_IP "test -e /var/run/reboot-required && reboot || true"
sleep 5

set +e
while ! ssh root@$PUBLIC_IP ls ; do sleep 5 ; done
set -e

# Disk stuff
ssh root@$PUBLIC_IP "DEBIAN_FRONTEND=noninteractive apt-get -q -y install lvm2 parted"

# Network stuff
ssh root@$PUBLIC_IP "DEBIAN_FRONTEND=noninteractive apt-get -q -y install bridge-utils"

# Build Requirements
ssh root@$PUBLIC_IP "DEBIAN_FRONTEND=noninteractive apt-get -q -y install git aptitude python-dev python-setuptools"

# Not-crappy editors + tools
ssh root@$PUBLIC_IP "DEBIAN_FRONTEND=noninteractive apt-get -q -y install emacs24-nox vim tmux"

# Get modern pip
ssh root@$PUBLIC_IP "easy_install pip"

#install ansible
ssh root@$PUBLIC_IP "pip install ansible==1.6.6"