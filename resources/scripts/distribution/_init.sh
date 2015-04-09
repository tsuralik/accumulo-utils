echo $# args
if [ $# -eq 0 ]
  then
    echo "No arguments supplied - must specify 'fast' or 'slow'"
    usePauses=0
    exit
  else
    echo "Arguments supplied"
    if [ "slow" == "$1" ]
       then
           echo "Use Pauses"
           usePauses=1
       else
           if [ "fast" == "$1" ]
              then 
                  echo "Skip Pauses"
                  usePauses=0
              else
                  echo "invalid argument '$1' - must specify 'fast' or 'slow'"
                  exit
           fi
    fi
fi

if [ $usePauses -eq 1 ]
  then
    echo "Using Pauses"
    read -p "Press enter to continue..."
    echo "See!?"
  else
    echo "Ignoring Pauses"
fi

echo CREATE BACKUP DIR
mkdir -p backups

echo BACKUP /etc/ssh/ssh_config
cp /etc/ssh/ssh_config ./backups/backup.etc-ssh-ssh_config
echo UPDATE StrictHostKeyChecking TO no
sed -i "s/# *StrictHostKeyChecking ask/StrictHostKeyChecking no/" /etc/ssh/ssh_config
echo CREATE SSH KEY
ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa
echo ADD SSH KEY TO AUTHORIZED KEYS
cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys 
chmod 600 ~/.ssh/authorized_keys 

#echo Run 'ssh localhost' in another terminal
ssh localhost 'exit'

echo LOG KNOWN HOSTS TO THE CONSOLE
cat ~/.ssh/known_hosts

read -p "Press enter to continue..."

echo ESTABLISH CRON JOB FOR PINGING YAHOO
echo COPY THE FOLLOWING INTO crontab -e
echo "* * * * * ping -c 1 yahoo.com > /dev/null 2>&1"

read -p "Press enter to continue..."

echo VERIFY CRON LOG IN /var/log/cron
echo "USE date; ls -lt /var/log/cron"
echo USE cat /var/log/cron

read -p "Press enter to continue..."

echo BACKUP /etc/selinux/config
cp /etc/selinux/config ./backups/backup.etc--selinux--config
echo BACKUP /proc/sys/vm/swappiness
cp /proc/sys/vm/swappiness ./backups/backup.proc--sys--vm--swappiness
echo BACKUP /etc/sysctl.conf
cp /etc/sysctl.conf ./backups/backup.etc--sysctl.conf

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo DISABLE SELINUX
sed -i "s/SELINUX=enforcing/SELINUX=disabled/" /etc/selinux/config 
echo CHANGED SWAPPINESS TO 2
echo 2 > /proc/sys/vm/swappiness
echo vm.swappiness = 2 >> /etc/sysctl.conf

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo DOWNLOAD CLOUDERA CDH5 AND ACCUMULO REPO FILES TO /etc/yum.repos.d/
curl http://archive.cloudera.com/cdh5/redhat/6/x86_64/cdh/cloudera-cdh5.repo > /etc/yum.repos.d/cloudera-cdh5.repo
curl http://archive.cloudera.com/accumulo-c5/redhat/6/x86_64/cdh/cloudera-accumulo.repo > /etc/yum.repos.d/cloudera-accumulo.repo

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo YUM INSTALL HTTPD
yum install -y httpd
echo CONFIGURE HTTPD
chkconfig --levels 235 httpd on
 
if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo PUSH CWD ONTO STACK
pushd .
cwd=$(pwd)
echo Current working directory is $cwd

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo YUM INSTALL createrepo
yum install -y yum-utils createrepo
cd /var/www/html/
echo CREATE /var/www/html/yum DIRECTORY
mkdir yum
cd yum/
reposync --repoid=cloudera-cdh5
ls
cd cloudera-cdh5/

echo POP BACK TO ORIGINAL WORKING DIRECTORY
popd 
cwd=$(pwd)
echo Current working directory is $cwd

echo COPY JDK RPM TO CDH5 REPO DIRECTORY
cp ./init-files/jdk-7u67-linux-x64.rpm /var/www/html/yum/cloudera-cdh5
ls -l /var/www/html/yum/cloudera-cdh5 | grep jdk

echo PUSH CWD ONTO STACK
pushd .
cwd=$(pwd)
echo Current working directory is $cwd

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo CREATE YUM REPO FOR CLOUDERA CDH5
cd /var/www/html/yum/cloudera-cdh5
createrepo .

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo CREATE YUM REPO FOR CLOUDERA ACCUMULO
cd /var/www/html/yum/
reposync --repoid=cloudera-accumulo
cd cloudera-accumulo/
createrepo .

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo POP BACK TO ORIGINAL WORKING DIRECTORY
popd 
cwd=$(pwd)
echo Current working directory is $cwd

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo START HTTPD SERVICE
service httpd start

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo COPY MODIFIED CLOUDERA CDH5 AND ACCUMULO REPO FILES TO /etc/yum.repos.d/
cp ./init-files/cloudera-cdh5.repo /etc/yum.repos.d
cp ./init-files/cloudera-accumulo.repo /etc/yum.repos.d

echo YUM CLEAN
yum clean
echo YUM REPOLIST
yum repolist

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo YUM INSTALL jdk, hadoop-conf-pseudo, and zookeeper-server
yum install -y jdk hadoop-conf-pseudo zookeeper-server

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo YUM INSTALL accumulo services
yum install -y accumulo-master accumulo-monitor accumulo-gc accumulo-tracer accumulo-tserver accumulo #accumulo-logger

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo DISABLE IPTABLES AND IP6TABLES
service iptables stop
service ip6tables stop
chkconfig iptables off
chkconfig ip6tables off

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo REMOVE ACCUMULO FROM AUTO-STARTUP
for x in $(ls /etc/init.d | grep accumulo); do echo $x; chkconfig $x off; done

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo export HADOOP_CLIENT_HOME
export HADOOP_CLIENT_HOME=/usr/lib/hadoop/client
echo FORMAT NAME NODE
sudo -u hdfs hdfs namenode -format

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo BACKUP /etc/hadoop/conf/hdfs-site.xml
cp -p /etc/hadoop/conf/hdfs-site.xml ./backups/backup.etc--hadoop--conf--hdfs-site.xml 
echo COPY PREPARED hdfs-site.xml TO /etc/hadoop/conf/
cp ./init-files/etc--hadoop--conf--hdfs-site.xml /etc/hadoop/conf/hdfs-site.xml

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo START HADOOP HDFS SERVICES
sudo service hadoop-hdfs-namenode start 
echo sleeping for 15 seconds...
sleep 5
echo sleeping for 10 more seconds...
sleep 5
echo sleeping for  5 more seconds...
sleep 5
echo waking up...
sudo service hadoop-hdfs-secondarynamenode start 
sudo service hadoop-hdfs-datanode start 

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo CREATE /tmp/hadoop-yarn HDFS DIRECTORIES
sudo -u hdfs hdfs dfs -mkdir -p /tmp/hadoop-yarn/staging/history/done_intermediate
sudo -u hdfs hdfs dfs -chown -R mapred:mapred /tmp/hadoop-yarn/staging
sudo -u hdfs hdfs dfs -chmod -R 1777 /tmp
echo CREATE /var/log/hadoop-yarn HDFS DIRECTORIES
sudo -u hdfs hdfs dfs -mkdir -p /var/log/hadoop-yarn
sudo -u hdfs hdfs dfs -chown yarn:mapred /var/log/hadoop-yarn
sudo -u hdfs hdfs dfs -mkdir -p /var/log/yarn
sudo -u hdfs hdfs dfs -chown yarn:mapred /var/log/hadoop-yarn
echo CREATE /user/root HDFS DIRECTORIES
sudo -u hdfs hdfs dfs -mkdir -p /user/root
sudo -u hdfs hdfs dfs -chown root /user/root
sudo -u hdfs hdfs dfs -chmod 755 /user/root

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo LIST CURRENT HDFS DIRECTORY STRUCTURE
sudo -u hdfs hadoop fs -ls -R /

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo INITIALIZE ZOOKEEPER SERVER
service zookeeper-server init

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo BACKUP /etc/accumulo/conf/accumulo-site.xml
cp -p /etc/accumulo/conf/accumulo-site.xml ./backups/backup.etc--accumulo--conf--accumulo-site.xml
echo COPY PREPARED accumulo-site.xml TO /etc/accumulo/conf/
cp ./init-files/etc--accumulo--conf--accumulo-site.xml /etc/accumulo/conf/accumulo-site.xml

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo CONFIGURE /var/lib/accumulo/walogs PERMISSIONS
chmod 1777 /var/lib/accumulo/walogs/

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo CREATE /accumulo HDFS DIRECTORIES
sudo -u hdfs hdfs dfs -mkdir /accumulo
sudo -u hdfs hdfs dfs -chown accumulo:supergroup /accumulo
sudo -u hdfs hdfs dfs -chmod 755 /accumulo
echo CREATE /user/accumulo HDFS DIRECTORIES
sudo -u hdfs hdfs dfs -mkdir -p /user/accumulo
sudo -u hdfs hdfs dfs -chown accumulo:supergroup /user/accumulo
sudo -u hdfs hdfs dfs -chmod 755 /user/accumulo

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo BACKUP /root/.bashrc
cp /root/.bashrc ./backups/backup.bashrc.step-1

echo export HADOOP_CLIENT_HOME TO /root/.bashrc
echo export HADOOP_HOME TO /root/.bashrc
echo export HADOOP_PREFIX TO /root/.bashrc
echo export ACCUMULO_HOME TO /root/.bashrc

export HADOOP_CLIENT_HOME=/usr/lib/hadoop/client >> /root/.bashrc
export HADOOP_HOME=/usr/lib/hadoop >> /root/.bashrc
export HADOOP_PREFIX=/usr/lib/hadoop >> /root/.bashrc
export ACCUMULO_HOME=/usr/lib/accumulo >> /root/.bashrc

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo START ZOOKEEPER-SERVER
service zookeeper-server start

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo START HADDOP MAPREDUCE HISTORYSERVER
service hadoop-mapreduce-historyserver start
echo START HADDOP YARN NODEMANAGER
service hadoop-yarn-nodemanager start
echo START HADDOP YARN RESOURCEMANAGER
service hadoop-yarn-resourcemanager start

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo CREATE hadoop_smoke_test DIRECTORY
mkdir ./hadoop_smoke_test
echo CREATE SMOKE TEST FILE
find / > ./hadoop_smoke_test/smoke_test_hadoop_file_listing.txt
sed -i "s/\// /g" ./hadoop_smoke_test/smoke_test_hadoop_file_listing.txt
echo UPLOAD SMOKE TEST FILE TO HDFS
hdfs dfs -mkdir find
hdfs dfs -mkdir find/input
hdfs dfs -put ./hadoop_smoke_test/smoke_test_hadoop_file_listing.txt find/input
echo RUN MAPREDUCE
hadoop jar /usr/lib/hadoop-mapreduce/hadoop-mapreduce-examples.jar wordcount find/input find/output
echo DOWNLOAD MAPREDUCE RESULTS TO LOCAL FILESYSTEM
hdfs dfs -cat find/output/part-r-00000 > ./hadoop_smoke_test/smoke_test_hadoop_results.part-r-00000.txt 
echo LOG 25 LINES OF THE RESULTS TO THE CONSOLE
head -n 25 ./hadoop_smoke_test/smoke_test_hadoop_results.part-r-00000.txt 

read -p "Press enter to continue..."

echo STOP HADDOP MAPREDUCE HISTORYSERVER
service hadoop-mapreduce-historyserver stop
echo STOP HADDOP YARN NODEMANAGER
service hadoop-yarn-nodemanager stop
echo STOP HADDOP YARN RESOURCEMANAGER
service hadoop-yarn-resourcemanager stop

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo STOP IPTABLES and IP6TABLES AGAIN
service iptables stop
service ip6tables stop

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo BACKUP /usr/lib/accumulo/bin/bootstrap_config.sh
cp -p /usr/lib/accumulo/bin/bootstrap_config.sh ./backups/backup.usr-lib-accumulo-bin-bootstrap_config.sh
echo CONFIGURE /usr/lib/accumulo/bin/bootstrap_config.sh FOR 3GB EXAMPLE ENVIRONMENT
sed -i "s/conf\/templates/conf\/examples\/3GB\/standalone/g" /usr/lib/accumulo/bin/bootstrap_config.sh

echo LOG PROPER SETTINGS FOR BOOTSTRAP CONFIGURATION TO THE CONSOLE
echo "SELECT THE FOLLOWING SETTINGS: 3GB | Java | HADOOP 2"

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo RUN ACCUMULO BOOTSTRAP CONFIGURATION FOR THE USER
/usr/lib/accumulo/bin/bootstrap_config.sh

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo BACKUP /usr/lib/accumulo/conf/accumulo-env.sh
cp -p /usr/lib/accumulo/conf/accumulo-env.sh ./backups/backup.usr--lib--accumulo--conf--accumulo-env.sh
echo UPDATE /usr/lib/accumulo/conf/accumulo-env.sh FOR HADOOP, JAVA, and ZOOKEEPER PATHS
sed -i "s/\/path\/to\/hadoop/\/usr\/lib\/hadoop/g" /usr/lib/accumulo/conf/accumulo-env.sh
sed -i "s/\/path\/to\/java/\/usr\/java\/default/g" /usr/lib/accumulo/conf/accumulo-env.sh
sed -i "s/\/path\/to\/zookeeper/\/usr\/lib\/zookeeper/g" /usr/lib/accumulo/conf/accumulo-env.sh

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo BACKUP /usr/lib/accumulo/conf/accumulo-site.xml
cp -p /usr/lib/accumulo/conf/accumulo-site.xml ./backups/backup.usr--lib--accumulo--conf--accumulo-site.xml
echo COPY PREPARED accumulo-site.xml TO /usr/lib/conf/
cp ./init-files/usr--lib--accumulo--conf--accumulo-site.xml /usr/lib/accumulo/conf/accumulo-site.xml

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo STOP IPTABLES and IP6TABLES AGAIN
service iptables stop
service ip6tables stop

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo CONFIGURE /usr/lib/accumulo PERMISSIONS TO LET ACCUMULO CREATES LOGS IN A LOG DIRECTORY
chmod 777 /usr/lib/accumulo

if [ $usePauses -eq 1 ]; then read -p "Press enter to continue..."; else echo "Ignoring Pauses"; fi

echo RUN ACCUMULO INITIALIZATION
sudo -u accumulo /usr/lib/accumulo/bin/accumulo init

echo "USE accumulo-start-all.sh TO START ACCUMULO"

./accumulo-start-all.sh

read -p "Press enter to continue..."

echo "USE THE FOLLOWING COMMANDS TO VERIFY ACCUMULO:"
echo "getauths"
echo "createtable mytable"
echo "scan"
echo "insert -l public 'john doe' contact phone 555-1212"
echo "insert -l public 'john doe' contact city somewhere"
echo "scan"
echo "setauths -s public"
echo "scan"

echo "LAUNCHING THE ACCUMULO SHELL - THIS MAY TAKE A MOMENT..."
./accumulo-shell.sh
