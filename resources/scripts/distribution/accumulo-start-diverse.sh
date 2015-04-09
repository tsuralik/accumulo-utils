service accumulo-tserver start
sleep 10
#service accumulo-master start
#sleep 10
service accumulo-tracer start
sleep 5
service accumulo-monitor start
sleep 5
service accumulo-gc start
sleep 5
sudo -u accumulo /usr/lib/accumulo/bin/start-all.sh

