#!/bin/bash

set -x

nova volume-detach $SERVERNAME $LXC_VOLUME_ID
nova delete $SERVERNAME
nova volume-delete $LXC_VOLUME_NAME


sleep 20
set +x
echo "These should have no output:"
nova list | grep schof
nova volume-list | grep schof
echo "done with output"