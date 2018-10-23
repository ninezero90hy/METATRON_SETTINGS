#!/bin/bash

# run Hadoop
/Development/Hadoop/hadoop/sbin/start-dfs.sh
/Development/Hadoop/hadoop/sbin/start-yarn.sh

# run Hive - metastore
hive --service metastore > log/hive_metastore.log 2>&1 < /dev/null &

# run Hive - hiveserver2
hiveserver2 > log/hiveserver2.log 2>&1 < /dev/null &
