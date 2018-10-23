#!/bin/bash

# Stop Hadoop
/Development/Hadoop/hadoop/sbin/stop-yarn.sh
/Development/Hadoop/hadoop/sbin/stop-dfs.sh

# kill Hive Process
kill -9 $(jps -m | grep "hive" | awk '{ print $1 }')
