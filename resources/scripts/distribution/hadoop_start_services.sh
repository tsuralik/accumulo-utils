service hadoop-hdfs-namenode start
echo sleeping for 15 seconds...
sleep 5
echo sleeping for 10 more seconds...
sleep 5
echo sleeping for  5 more seconds...
sleep 5
echo waking up...
service hadoop-hdfs-secondarynamenode start
service hadoop-hdfs-datanode start
