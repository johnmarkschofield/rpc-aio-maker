#!/bin/bash

set -o pipefail
set -u
source cloudenv
set -x


there_are_things_to_delete(){
    if nova list | grep ${AIONAME} ; then
        return 0
    fi

    if nova volume-list | grep ${AIONAME} ; then
        return 0
    fi 

    if nova network-list | grep ${AIONAME} ; then
        return 0
    fi

    return 1
}



while there_are_things_to_delete ; do
    echo "Removing all elements associated with $AIONAME"


    if nova list | grep $AIONAME ; then
        echo "Deleting servers..."
        nova delete $SERVERNAME
    fi

    if nova volume-list | grep $AIONAME ; then        
        echo "Deleting volumes..."
        nova volume-delete $LVM_VOLUME_ID
    fi

    if nova network-list | grep $AIONAME ; then
        echo "Deleting networks..."
        nova network-delete $MGMT_NETWORK_ID
        nova network-delete $VXLAN_NETWORK_ID
        nova network-delete $STORAGE_NETWORK_ID
    fi

done
