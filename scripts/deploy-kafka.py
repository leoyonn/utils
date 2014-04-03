#!/usr/bin/env python
#coding=utf-8
#
# @author leo [liuy@xiaomi.com]
# @date 2013-12-04
# generate kafka configs for a kafka-cluster and deploy this cluster.
#################################################################################

import os, sys, string, yaml
from time import sleep
from release_utils import p1 as p, load_yaml, full_path
from gen_conf import gen_conf

# check input validation
args = sys.argv
if len(args) < 2:
    p('Usage: %s path-to-config.yaml' % __file__)
    sys.exit(1)

ZK_CLIENT = '/opt/soft/zookeeper/bin/zkCli.sh'
if not os.path.isfile(ZK_CLIENT):
    p('Please install zookeeper on this deploy machine:\n\t' +
            'http://sxinstall.n.miliao.com/index.php?do=release&project=zookeeper&server=${ip}')
    sys.exit(1)

# check if need to download
KAFKA_VER = 'kafka_2.8.0-0.8.0'
KAFKA_URL = 'http://mirror.bit.edu.cn/apache/kafka/0.8.0/%s.tar.gz' % KAFKA_VER
src = '/opt/soft/%s' % KAFKA_VER
pwd = os.path.dirname(os.path.dirname(full_path(__file__)).replace('/./', '/'))
if not os.path.isdir(src):
    if not os.path.isfile(src + '.tar.gz'):
        os.system('cd /opt/soft && wget ' + KAFKA_URL)
    os.system('cd /opt/soft && tar -xzvf %s.tar.gz' % KAFKA_VER)

# load config
os.system('rm -rf /tmp/kafka; mkdir -p /tmp/kafka')
conf = load_yaml(args[1])
p('Loaded configs: %s' % conf)
cluster_id = conf['cluster_id']
zk = conf['zookeeper']
user = conf['user'] if conf.has_key('user') else 'root' 

# create cluster root on zookeeper
os.system(('%(ZK_CLIENT)s -server %(zk)s create /kafka null;' +
        '%(ZK_CLIENT)s -server %(zk)s create /kafka/cluster-%(cluster_id)s null;') % locals())

# prepare package/config for each broker and deploy
for broker in conf['brokers']:
    broker_id = broker['id']
    host = broker['host']
    port = broker['port']
    jmx_port = str(int(port) + 900)
    local_dir = '/tmp/kafka/%(cluster_id)s.%(broker_id)s' % locals()
    remote_dir = '/opt/soft/kafka/%(cluster_id)s.%(broker_id)s' % locals()
    os.system('cp -r %(src)s %(local_dir)s' % locals())
    # generate server.properties
    gen_conf((('%(pwd)s/conf/kafka/server.template %(local_dir)s/config/server.properties ' +
        'cluster_id=%(cluster_id)s broker_id=%(broker_id)s host=%(host)s port=%(port)s zk=%(zk)s') %
        locals()).split(' '))
    # generate log4j.properties
    gen_conf((('%(pwd)s/conf/kafka/log4j.template %(local_dir)s/config/log4j.properties ' +
        'cluster_id=%(cluster_id)s broker_id=%(broker_id)s') % locals()).split(' '))
    # generate start.sh 
    gen_conf((('%(pwd)s/conf/kafka/start.sh.template %(local_dir)s/start.sh ' +
        'cluster_id=%(cluster_id)s broker_id=%(broker_id)s jmx_port=%(jmx_port)s') % locals()).split(' '))
    # generate stop.sh 
    gen_conf((('%(pwd)s/conf/kafka/stop.sh.template %(local_dir)s/stop.sh ' +
        'cluster_id=%(cluster_id)s broker_id=%(broker_id)s') % locals()).split(' '))
    # prepare remote path and deploy
    cmd = ('ssh %(user)s@%(host)s "mkdir -p /opt/soft/kafka; ' +
        'rm -rf %(remote_dir)s; mkdir -p /data/soft/kafka/%(cluster_id)s.%(broker_id)s/logs;";\n' +
        'scp -r %(local_dir)s %(user)s@%(host)s:%(remote_dir)s;\n' +
        'ssh %(user)s@%(host)s "sh %(remote_dir)s/start.sh"\n') % locals()
    p('Deploy with following command:\n' + cmd)
    os.system(cmd)
    p('Deploy broker: %(broker)s done!' % locals())
    sleep(1)

