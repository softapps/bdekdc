#!/usr/bin/env bash
set -e
echo "Set cloudera-manager.repo to CM v5"
yum clean all
RELEASEVER=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release))
rpm --import http://10.0.10.251/repo/cdh593/cdh5/redhat/$RELEASEVER/x86_64/cdh/RPM-GPG-KEY-cloudera
wget http://10.0.10.251/repo/cdh593/cm5/redhat/$RELEASEVER/x86_64/cm/cloudera-manager.repo -O /etc/yum.repos.d/cloudera-manager.repo
yum install -y oracle-j2sdk* cloudera-manager-{daemons,agent}

echo "Setup NTP"
sed -i -e "s/server 0.centos.pool.ntp.org iburst/server 2.in.pool.ntp.org/g" /etc/ntp.conf
sed -i -e "s/server 1.centos.pool.ntp.org iburst/server 0.asia.pool.ntp.org/g" /etc/ntp.conf
sed -i -e "s/server 2.centos.pool.ntp.org iburst/server 1.asia.pool.ntp.org/g" /etc/ntp.conf
sed -i -e "s/server 3.centos.pool.ntp.org iburst/server 2.asia.pool.ntp.org/g" /etc/ntp.conf
service ntpd restart
