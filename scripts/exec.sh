#!/bin/bash

source /etc/profile
here=`pwd`
JVM_PROPERTIES=" -Xms1024m -Xmx4096m -Xmn512M -XX:MaxDirectMemorySize=1000M -XX:MaxPermSize=128M -XX:+UseConcMarkSweepGC -Xss512K -XX:+UseParNewGC -XX:+PrintReferenceGC "

JAVA_PROPERTIES="-XX:+HeapDumpOnOutOfMemoryError -XX:HeapDumpPath=/tmp -verbose:gc -Xloggc:gc.log -XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCApplicationStoppedTime -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false $JAVA_PROPERTIES"

classpath="${here}/target:${here}/target/classes:${here}/target/test-classes"
for jarpath in `ls ${here}/target/library/*.jar`; do
    classpath=${classpath}:${jarpath}
done

execClass="com.xiaomi.xmpush.exec.Executor"
exec java ${JAVA_PROPERTIES} ${JVM_PROPERTIES} -classpath ${classpath} ${execClass} $@
