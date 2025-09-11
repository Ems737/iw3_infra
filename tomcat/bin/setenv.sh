#!/bin/sh
export CATALINA_OPTS="$CATALINA_OPTS -Xmx1024m"
export CATALINA_OPTS="$CATALINA_OPTS -Xms512m"
export JAVA_OPTS="$JAVA_OPTS -Duser.timezone=$TZ"

