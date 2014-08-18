#!/bin/bash
set -e
set -o pipefail
set -u
# source cloudenv
set -x

source ~/openrc


# Configure Networking
neutron net-create testing1
PUBLIC_NET_ID=`neutron net-show testing1 | grep -E "\| id\W*\|" | awk '{print $4}'`
neutron subnet-create testing1 192.168.10.0/24


# Set up public key
sh-keygen -t dsa -q -f ~/.ssh/id_dsa -N ""
nova keypair-add --pub-key ~/.ssh/id_dsa.pub adminkey

# Create First Image
cd ~
wget http://download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img
glance image-create --name cirrostest \
    --disk-format qcow2 --container-format bare \
    --file cirros-0.3.2-x86_64-disk.img \
    --progress



# Create first VM
nova boot \
    --flavor m1.tiny \
    --image cirrostest \
    --key-name adminkey \
    --security-groups default \
    --nic net-id=$PUBLIC_NET_ID \
    --poll \
    cirrostest1


##### on neutron-agents-container:
ip netns exec qdhcp-975c4316-ade8-4402-b475-7492bcfc3a4c iptables -A POSTROUTING -t mangle -p udp --dport 68 -j CHECKSUM --checksum-fill
