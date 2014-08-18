#!/bin/bash

set -e
set -o pipefail
set -u
source cloudenv
set -x

while [ `ssh root@$PUBLIC_IP 'fdisk -l | grep "Disk /dev/"  | wc -l'` -ne 3 ]; do
	 sleep 5
done


# Configure Disks
ssh root@$PUBLIC_IP parted -s /dev/xvde mktable gpt                                                              
ssh root@$PUBLIC_IP parted -s /dev/xvdb mktable gpt
ssh root@$PUBLIC_IP parted -s /dev/xvde mkpart lvm 0% 100%                                                       
ssh root@$PUBLIC_IP parted -s /dev/xvdb mkpart lvm 0% 100%   
ssh root@$PUBLIC_IP pvcreate /dev/xvde1    
ssh root@$PUBLIC_IP pvcreate /dev/xvdb1                                                                           
ssh root@$PUBLIC_IP vgcreate lxc /dev/xvdb1                                                                                                                                              
ssh root@$PUBLIC_IP vgcreate cinder-volumes /dev/xvde1 
