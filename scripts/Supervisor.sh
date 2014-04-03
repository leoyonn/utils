#!/bin/bash
#this script must run under the service working directory.

LANG="en_US.UTF-8"
export LANG

STARTUP=`date`
echo "startup time: ${STARTUP}"
DIR=`pwd -P`
echo "server version:${DIR}"

source /etc/profile
source ../classes/envs.properties

#export JAVA_PROPERTIES="-Dcom.sun.management.jmxremote.port=57912"
JVM_PROPERTIES=" -Xms1024m -Xmx4096m -Xmn512M -XX:MaxDirectMemorySize=1000M -XX:MaxPermSize=128M -XX:+UseConcMarkSweepGC -Xss512K -XX:+UseParNewGC -XX:+UseCompressedOops -XX:+PrintReferenceGC "

JAVA_PROPERTIES="-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp -verbose:gc -Xloggc:gc.log -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCApplicationStoppedTime -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false $JAVA_PROPERTIES ${hbase_kerberos}"

echo ${JAVA_PROPERTIES}

#classpath="configuration:`basename xmpush-*.jar`:./classes"
classpath="configuration:../classes"

for jarpath in `ls ../library/*.jar`
do
        classpath=$classpath:$jarpath
done
exec java $JAVA_PROPERTIES ${JVM_PROPERTIES} -classpath $classpath $@ -r -ip $(hostname -i)
