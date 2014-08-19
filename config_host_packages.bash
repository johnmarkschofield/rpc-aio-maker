#!/bin/bash

set -e
set -o pipefail
set -u
source cloudenv
set -x

ssh -o StrictHostKeyChecking=no root@$PUBLIC_IP "true"

ssh root@$PUBLIC_IP "echo deb [arch=amd64] http://dc0e2a2ef0676c3453b1-31bb9324d3aeab0d08fa434012c1e64d.r5.cf1.rackcdn.com LA main > /etc/apt/sources.list"
ssh root@$PUBLIC_IP "curl http://dc0e2a2ef0676c3453b1-31bb9324d3aeab0d08fa434012c1e64d.r5.cf1.rackcdn.com/repo.gpg | apt-key add -"
ssh root@$PUBLIC_IP "apt-get update"
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