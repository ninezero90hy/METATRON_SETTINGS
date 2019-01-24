#echo "Stop Mysql"
#mysql.server stop

echo "Stop Hadoop"
stop-dfs.sh
stop-yarn.sh

echo "Stop Hive"
ps -ef | grep org.apache.hadoop.hive.metastore.HiveMetaStore | grep -v grep | awk '{print $2}' | xargs kill -9
ps -ef | grep org.apache.hive.service.server.HiveServer2 | grep -v grep | awk '{print $2}' | xargs kill -9
ps -ef | grep org.apache.hive.beeline.BeeLine | grep -v grep | awk '{print $2}' | xargs kill -9

echo "Stop druid"
ps -ef | grep io.druid.cli.Main | grep -v grep | awk '{print $2}' | xargs kill -9
ps -ef | grep io.druid.cli.ServerRunnable | grep -v grep | awk '{print $2}' | xargs kill
