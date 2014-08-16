#!/bin/bash

source cloudenv

set -x



there_are_things_to_delete(){
    if nova list | grep $SERVERNAME ; then
        return 0
    fi

    if nova volume-list | grep $LXC_VOLUME_NAME ; then
        return 0
    fi 

    if nova network-list | grep $MGMT_NETWORK_NAME ; then
        return 0
    fi

    if nova network-list | grep $VMNET_NETWORK_NAME ; then
        return 0
    fi

    return 1
}



while there_are_things_to_delete ; do
    echo "Removing all AIO elements associated with $SERVERNAME"
    nova stop $SERVERNAME
    nova volume-detach $SERVERNAME $LXC_VOLUME_ID
    sleep 15
    nova delete $SERVERNAME
    nova volume-delete $LXC_VOLUME_NAME
    nova network-delete $MGMT_NETWORK_ID
    nova network-delete $VMNET_NETWORK_ID
    sleep 10
done
