#!/bin/bash

baseDir="./"
libDir="${baseDir}lib/"
CLASSPATH="${baseDir}build/classes/:${baseDir}build/tool/classes/:${baseDir}build/test/:${baseDir}build/tool/"

for f in ${libDir}*.jar; do
  CLASSPATH=${CLASSPATH}:$f;
done
echo "NOTICE: run this bash at folder with build.xml. related path is ./bin/*.sh"
if [ "$1" = "-profile" ] || [ "$1" = "-p" ] ; then
echo "PROFILE WITH JIP. TO MODIFY CONFIG FOR PROFILE, YOU CAN MODIFY: ${libDir}profile.properties"
shift
JAVACMD="java -Xmx2g -classpath $CLASSPATH -javaagent:${libDir}profile.jar -Dprofile.properties=${libDir}profile.properties $*"
fi

if [ "$1" = "" ]; then
JAVACMD="echo \"USAGE: runjava.sh <-profile> [JAVA_CMD_PARAS]\""
else
JAVACMD="java -Xmx2g -classpath $CLASSPATH $*"
fi
echo $JAVACMD
exec $JAVACMD
