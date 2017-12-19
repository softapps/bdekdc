#!/usr/bin/env bash
set -e
echo "Set cloudera-manager.repo to CM v5"
yum clean all
RELEASEVER=$(rpm -q --qf "%{VERSION}" $(rpm -q --whatprovides redhat-release))
rpm --import http://10.0.10.251/repo/cdh593/cdh5/redhat/$RELEASEVER/x86_64/cdh/RPM-GPG-KEY-cloudera
wget http://10.0.10.251/repo/cdh593/cm5/redhat/$RELEASEVER/x86_64/cm/cloudera-manager.repo -O /etc/yum.repos.d/cloudera-manager.repo
yum install -y oracle-j2sdk* cloudera-manager-{daemons,server,server-db*}

echo "start cloudera-scm-server-db and cloudera-scm-server services"
service cloudera-scm-server-db start
service cloudera-scm-server start

export PGPASSWORD=$(head -1 /var/lib/cloudera-scm-server-db/data/generated_password.txt)
SCHEMA=("hive" "sentry")
for DB in "${SCHEMA[@]}"; do
    echo "Create $DB Database in Cloudera embedded PostgreSQL"
    SQLCMD=("CREATE ROLE $DB LOGIN PASSWORD 'cloudera';" "CREATE DATABASE $DB OWNER $DB ENCODING 'UTF8';" "ALTER DATABASE $DB SET standard_conforming_strings = off;")
    for SQL in "${SQLCMD[@]}"; do
        psql -A -t -d scm -U cloudera-scm -h localhost -p 7432 -c """${SQL}"""
    done
done

echo "Set KDH keytab & principal"
#cd /tmp
#wget http://10.0.10.251/repo/kdc/cmf.tar.gz
#tar -xvf cmf.tar.gz
#mv /tmp/cmf.keytab /etc/cloudera-scm-server/
#chown cloudera-scm:cloudera-scm /etc/cloudera-scm-server/cmf.keytab
#chmod 600 /etc/cloudera-scm-server/cmf.keytab

echo "tunde/admin@COMPUTE.INTERNAL" > /etc/cloudera-scm-server/cmf.principal
chown cloudera-scm:cloudera-scm /etc/cloudera-scm-server/cmf.principal
chmod 600 /etc/cloudera-scm-server/cmf.principal

while ! (exec 6<>/dev/tcp/$(hostname)/7180) 2> /dev/null ; do echo 'Waiting for Cloudera Manager to start accepting connections...'; sleep 10; done
