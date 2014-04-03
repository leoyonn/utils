#!/bin/bash
# Author chenqiliang@xiaomi.com
# Monitor xmpush current max-uuid, and check delta with xmq partition, so that notify to create new xmq partions.

# Must install xmp-* into target machines. Find these scripts in xmpush/scripts/xmp
xmq_upper_bound=`/usr/bin/xmp-xmq-upperbound`
max_uuid=`/usr/bin/xmp-max-uuid |awk -F'=' '{print $2}'`

left_num=`expr $xmq_upper_bound - $max_uuid`

developers="chenqiliang@xiaomi.com liuy@xiaomi.com qifuguang@xiaomi.com qujinping@xiaomi.com oujinliang@xiaomi.com wangbin@xiaomi.com wangxuanran@xiaomi.com wuxiaojun@xiaomi.com"

if (( $left_num < 8000000 )); then
    # Send notify to developers
    echo "NOTICE: XmPush max uuid $max_uuid, xmq upper bound $xmq_upper_bound,  left $left_num"
    for recv in $developers ; do
        /usr/bin/curl -d "subject=XmPush_UUID_NOTICE&body=XmPush current uuid ${max_uuid}, xmq upper bound ${xmq_upper_bound},  left ${left_num} . Maybe expand xmq&to=${recv}&s=xiaomi.commiliao" http://operation.chat.xiaomi.net/m123
    done
fi

if (( $left_num < 4000000 )); then
    # Send alert to message team in miliao group.
    /usr/bin/curl -d "subject=XmPush_UUID_NOTICE&body=XmPush current uuid ${max_uuid}, xmq upper bound ${xmq_upper_bound},  left ${left_num}&to=muc.134219.nydvtn@m.miliao.com&s=xiaomi.commiliao" http://operation.chat.xiaomi.net/m123
fi


