#!/bin/bash

echo "#######################################"
echo "# metatron start ALL"
echo "#######################################"
sleep 1
source ~/.bashrc
echo "---------------------------------------"
echo "### MariaDB start ###"
# mysql.server restart
usr/local/bin/mysql.server restart
sleep 6
echo "---------------------------------------"
echo "### hadoop dfs start ###"
#start-dfs.sh
cd /Development/Hadoop/hadoop/sbin
./start-dfs.sh
sleep 6
echo "### hadoop yarn start ###"
cd /Development/Hadoop/hadoop/sbin
./start-yarn.sh
sleep 6
echo "---------------------------------------"
echo "### hive metastore start ###"
hive --service metastore > $HIVE_HOME/log/hive_metastore.log 2>&1 < /dev/null &
sleep 6
echo "### hive server2 start ###"
hiveserver2 > $HIVE_HOME/log/hiveserver2.log 2>&1 < /dev/null &
sleep 10

echo "### hive beeline start ###"
beeline -u jdbc:hive2://localhost:10000 &
sleep 15
echo
echo
echo
pid=$!
pid=$!
pid=$!


echo "---------------------------------------"
sleep 1
echo "### druid start ###"
#cd /Users/choong/dev/server/druid-0.9.1
cd /Development/Hadoop/druid/druid-0.9.1-SNAPSHOT.3.1.0.201812070238-hadoop-2.7.3
./start-single.sh
sleep 5
echo "#######################################"
echo "# metatron started ALL"
echo "#######################################"
