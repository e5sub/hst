#!/bin/bash
sleep 60s
#chkconfig:2345 61 61
#启动进程
JAVA_OPT="-Xms256m -Xmx512m --add-opens java.base/java.lang=ALL-UNNAMED --add-opens java.base/java.math=ALL-UNNAMED --add-opens java.base/java.io=ALL-UNNAMED --add-opens java.base/java.util=ALL-UNNAMED --add-opens java.base/java.util.concurrent=ALL-UNNAMED --add-opens java.rmi/sun.rmi.transport=ALL-UNNAMED --add-opens java.base/java.lang.reflect=ALL-UNNAMED"

nohup /opt/jdk17/bin/java  -jar $JAVA_OPT /app/java/smart-gateway.jar >/app/java/smart-gateway`date +%Y%m%d`.log 2>&1 &
