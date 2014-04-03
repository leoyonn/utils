#!/bin/bash

HOSTS="sd-ml-im-mt06.bj sd-ml-im-mt07.bj sd-ml-im-mt08.bj sd-ml-im-mt09.bj sd-im-mt11.bj sd-im-mt12.bj sd-im-mt13.bj sd-im-mt14.bj"

for HOST in $HOSTS; do
    echo "scp to ${HOST}:/opt/soft/tools/monitor/"
    scp -rp monitor-xmq root@${HOST}:/opt/soft/tools/monitor/
done

