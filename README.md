# Metatron 로컬 개발환경 설정

## 설치전 준비
```bash
 cd /
 sudo mkdir -p /Development/Hadoop
 sudo chown -R -v '오너 이름' /Development/
 mv '해당 프로젝트 다운로드 경로'/metatron-settings /Development/
```

## MariaDB 설치
```bash
 brew update
 brew install mariadb
 brew services start mariadb

 # MariaDB 실행 관련 명령어
 # mysql.server status # 상태확인
 # mysql.server stop   # 정지
 # mysql.server start  # 실행
 # mysql -uroot        # 접속
```

## DB 생성 ( MySQL의 DB 생성 권한이 있는 계정으로 실행 )
```
 mysql -uroot

 # 테이블 생성 및 권한 부여
 create database hive_metastore_db;
 grant all privileges on *.* to 'hive'@'localhost' identified by 'hive' with grant option;
 grant all privileges on *.* to 'hive'@'%' identified by 'hive' with grant option;
 grant all privileges on hive_metastore_db.* to 'hive'@'%' identified by 'hive';

 # 생성확인
 select host from mysql.user where user='hive';
```

## ssh
```bash
 ssh-keygen -t rsa -P ""
 cat $HOME/.ssh/id_rsa.pub >> $HOME/.ssh/authorized_keys
 chmod 700 ~/.ssh
 chmod 600 ~/.ssh/authorized_keys
 ssh localhost

 #############################################################################################
 # SSH로 localhost 접속이 되지 않는 경우 처리
 # 참고 : (https://forums.macrumors.com/threads/ssh-connection-refused.1516735/)
 #############################################################################################
 sudo launchctl unload -w /System/Library/LaunchDaemons/ssh.plist
 sudo launchctl load -w /System/Library/LaunchDaemons/ssh.plist
 ssh -v localhost
 sudo launchctl list | grep "sshd"
 ssh localhost
 #############################################################################################
```

## Hadoop 설치
```bash
 cd /Development/Hadoop/
 wget http://apache.tt.co.kr/hadoop/common/hadoop-2.7.6/hadoop-2.7.6.tar.gz
 tar zxvf hadoop*.tar.gz
 mv hadoop-2.7.6.tar.gz ../
 mv hadoop-2.7.6/ hadoop
 cd hadoop
 mkdir tmp

 vi etc/hadoop/hadoop-env.sh
 #############################################################################################
 # hadoop-env.sh > HADOOP_HOME, HADOOP_CONF_DIR 수정
 #############################################################################################

 export HADOOP_HOME="/Development/Hadoop/hadoop"
 export HADOOP_CONF_DIR=${HADOOP_CONF_DIR:-"${HADOOP_HOME}/etc/hadoop"}

 # JAVA_HOME이 잡혀 있지 않은 경우 JAVA_HOME 추가
 # 확인은 편집창을 나가서 `echo $JAVA_HOME` 으로 확인가능
 #
 # e.g )
 # export JAVA_HOME=“/Library/Java/JavaVirtualMachines/jdk1.8.0_73.jdk/Contents/Home”
 # “/Library/Java/JavaVirtualMachines/jdk1.8.0_73.jdk/Contents/Home”는 자신의 경로로 바꿔준다
 #
 ##############################################################################################

 vi etc/hadoop/core-site.xml
 ##############################################################################################
 # core-site.xml > configuration 수정
 ##############################################################################################

 <configuration>
     <property>
         <name>fs.defaultFS</name>
         <value>hdfs://localhost:9000</value>
     </property>
     <property>
         <name>hadoop.tmp.dir</name>
         <value>'자신의 하둡 경로'/tmp</value>
     </property>
     <property>
         <name>hadoop.proxyuser.'오너 이름'.groups</name>
         <value>*</value>
     </property>
     <property>
         <name>hadoop.proxyuser.'오너 이름'.hosts</name>
         <value>*</value>
     </property>
 </configuration>

 #  -------------------------------------------------------------------------------------------
 #
 #  e.g ) 샘플 xml
 # <configuration>
 #     <property>
 #         <name>fs.defaultFS</name>
 #         <value>hdfs://localhost:9000</value>
 #     </property>
 #     <property>
 #         <name>hadoop.tmp.dir</name>
 #         <value>/Development/Hadoop/hadoop/tmp</value>
 #     </property>
 #     <property>
 #         <name>hadoop.proxyuser.gkoreamanr.groups</name>
 #         <value>*</value>
 #     </property>
 #     <property>
 #         <name>hadoop.proxyuser.gkoreamanr.hosts</name>
 #         <value>*</value>
 #     </property>
 # </configuration>
 ##############################################################################################

 vi etc/hadoop/hdfs-site.xml
 ##############################################################################################
 # hdfs-site.xml > configuration 수정
 ##############################################################################################

 <configuration>
     <property>
         <name>dfs.replication</name>
         <value>1</value>
     </property>
     <property>
        <name>dfs.webhdfs.enabled</name>
        <value>true</value>
     </property>
 </configuration>

 ##############################################################################################

 cp etc/hadoop/mapred-site.xml.template etc/hadoop/mapred-site.xml
 vi etc/hadoop/mapred-site.xml
 ##############################################################################################
 # mapred-site.xml > configuration 수정
 ##############################################################################################

 <configuration>
     <property>
         <name>mapreduce.framework.name</name>
         <value>yarn</value>
     </property>
 </configuration>

 ##############################################################################################

 vi etc/hadoop/yarn-site.xml
 ##############################################################################################
 # yarn-site.xml > configuration 수정
 ##############################################################################################

 <configuration>
     <!-- Site specific YARN configuration properties -->
     <property>
         <name>yarn.nodemanager.aux-services</name>
         <value>mapreduce_shuffle</value>
     </property>
 </configuration>

 ##############################################################################################

 # Hadoop 포맷 및 실행
 bin/hdfs namenode -format
 sbin/start-dfs.sh
 sbin/start-yarn.sh
```

## Hive 설치
```bash
 # 다운 및 압축해제
 cd ../
 tar xvfz ../metatron-settings/metatron-hive.tar.gz

 vi ~/.bashrc
 ##############################################################################################
 # 경로 추가 ( 하둡, 하이브 경로 설정 )
 ##############################################################################################
 #
 export HADOOP_HOME=하둡이 설치된 위치
 export HIVE_HOME=하둡이 설치된 위치/hive
 export PATH=$PATH:$HIVE_HOME/bin:$HADOOP_HOME/bin
 #
 # --------------------------------------------------------------------------------------------
 #
 # e.g )
 # export HADOOP_HOME=/Development/Hadoop/hadoop
 # export HIVE_HOME=/Development/Hadoop/hive
 # export PATH=$PATH:$HIVE_HOME/bin:$HADOOP_HOME/bin
 #
 ##############################################################################################

 # 경로 설정 적용
 source ~/.bashrc

 # HDFS 경로생성
 hadoop fs -mkdir /tmp
 hadoop fs -mkdir -p /user/hive/warehouse
 hadoop fs -chmod g+w /tmp
 hadoop fs -chmod g+w /user/hive/warehouse
 hadoop fs -chown '오너 이름' /user/hive
 hadoop fs -chown '오너 이름' /user/hive/warehouse
```

## Hive 관련 설정
```bash
 ##############################################################################################
 # Hive > hive-env.sh 수정
 ##############################################################################################
 vi $HIVE_HOME/conf/hive-env.sh
 #
 # 하둡 홈 경로 변경
 HADOOP_HOME=/Development/Hadoop/hadoop
 #
 ##############################################################################################

 # metastore 실행
 hive --service metastore > log/hive_metastore.log 2>&1 < /dev/null &
 # hiveserver2 실행
 hiveserver2 > log/hiveserver2.log 2>&1 < /dev/null &
 # beeline 실행
 beeline -u jdbc:hive2://localhost:10000

 # Hive 관련 스키마 SQL 실행
 mysql -uroot hive_metastore_db < /Development/Hadoop/hive/scripts/metastore/upgrade/mysql/hive-schema-1.2.0.mysql.sql

 # polaris 관련 DB 설정
 create database polaris CHARACTER SET utf8;
 grant all privileges on polaris.* TO polaris@localhost identified by 'polaris';
 grant all privileges on polaris.* TO polaris@'%' identified by 'polaris';
 create database polaris_datasources CHARACTER SET utf8;
 grant all privileges on polaris_datasources.* TO polaris@localhost identified by 'polaris';
 grant all privileges on polaris_datasources.* TO polaris@'%' identified by 'polaris';
 flush privileges;
```

## Druid 설정

- 드루이드는 메타트론 프로젝트의 README 확인후 변경 필요

- 오늘 날짜로 `druid-0.9.1-latest-hadoop-2.7.3-bin.tar.gz` 이 최신 버젼

- ![스크린샷 2019-01-17 오후 6.45.54](/Development/metatron-settings/스크린샷 2019-01-17 오후 6.45.54.png)

- 다운로드 링크 확인하는 방법

  - 드루이드는 메타트론 프로젝트의 README > Installation > `Druid customized version for Metatron` 링크주소 확인

  - 아래 스크립트의 바이너리 이름은 상황에 따라 적절히 변경이 필요

    ```shell
    # tar zxvf druid-0.9.1-latest-hadoop-2.7.3-bin.tar.gz
    # ./init.sh druid-0.9.1-SNAPSHOT.3.1.0.201812070238-hadoop-2.7.3
    ```

```bash
 cd /Development/Hadoop/
 mkdir druid
 cp ../metatron-settings/druid* druid
 cd druid
 unzip druid_bootstrap_init.zip
 tar zxvf druid-0.9.1-latest-hadoop-2.7.3-bin.tar.gz
 ./init.sh druid-0.9.1-SNAPSHOT.3.1.0.201812070238-hadoop-2.7.3
 cd druid
 ./start-single.sh
 cd ..
 cp ../../metatron-settings/ingestion.zip .
 unzip ingestion.zip
 cd ingestion

 vi index_sales_join_category_spec.json
 ##############################################################################################
 # index_sales_join_category_spec.json > baseDir 경로 수정
 ##############################################################################################
 #
 # baseDir="현재 경로"
 # --------------------------------------------------------------------------
 # e.g )
 # baseDir="/Development/Hadoop/druid/ingestion"
 #
 ##############################################################################################

 ./run_index.sh index_sales_join_category_spec.json
```

## start-all.sh / stop-all.sh 복사
```bash
 cd /Development/Hadoop/
 cp ../metatron-settings/start-all.sh .
 cp ../metatron-settings/stop-all.sh .
```

여기까지가 메타트론 설정입니다.

--

아래는 드루이드 엔진 버젼 패치 가이드

## Druid 엔진 패치시
```bash
1. 드루이드 정지
2. 드루이드 심볼릭 링크 제거
3. [드루이드 설정](https://gitlab.com/metatron/metatron-settings#druid-%EC%84%A4%EC%A0%95)
 - start-single.sh 까지만 하시면 됩니다.
```
