#!/bin/bash

APP_NAME="kestrel"
ADMIN_PORT="2223"
VERSION="2.4.1"
SCALA_VERSION="2.9.2"
APP_HOME="/docker-kestrel-home"
INITIAL_SLEEP=15

JAR_NAME="${APP_NAME}_${SCALA_VERSION}-${VERSION}.jar"
STAGE="production"
FD_LIMIT="262144"

HEAP_OPTS="-Xmx4096m -Xms4096m -XX:NewSize=768m"
GC_OPTS="-XX:+UseConcMarkSweepGC -XX:+UseParNewGC"
GC_TRACE="-XX:+PrintGCDetails -XX:+PrintGCTimeStamps -XX:+PrintGCDateStamps -XX:+PrintTenuringDistribution -XX:+PrintHeapAtGC"
GC_LOG="-Xloggc:/var/log/$APP_NAME/gc.log"
DEBUG_OPTS="-XX:ErrorFile=/var/log/$APP_NAME/java_error%p.log"

# allow a separate file to override settings.
test -f /etc/sysconfig/kestrel && . /etc/sysconfig/kestrel

JAVA_OPTS="-server -Dstage=$STAGE $GC_OPTS $GC_TRACE $GC_LOG $HEAP_OPTS $DEBUG_OPTS"

pidfile="/var/run/$APP_NAME/$APP_NAME.pid"
# This second pidfile exists for legacy purposes, from the days when kestrel
# was started by daemon(1)
daemon_pidfile="/var/run/$APP_NAME/$APP_NAME-daemon.pid"


TIMESTAMP=$(date +%Y%m%d%H%M%S);
# Move the existing gc log to a timestamped file in case we want to examine it.
# We must do this here because we have no option to append this via the JVM's
# command line args.
if [ -f /var/log/$APP_NAME/gc.log ]; then
    mv /var/log/$APP_NAME/gc.log /var/log/$APP_NAME/gc_$TIMESTAMP.log;
fi

ulimit -n $FD_LIMIT || echo -n " (no ulimit)"
ulimit -c unlimited || echo -n " (no coredump)"

CMD="echo "'$$'" > $pidfile; echo "'$$'" > $daemon_pidfile; \
exec ${JAVA_HOME}/bin/java ${JAVA_OPTS} \
-jar ${APP_HOME}/${JAR_NAME} \
>> /var/log/$APP_NAME/stdout 2>> /var/log/$APP_NAME/error"
echo "$CMD"
sh -c "$CMD"
