#!/usr/bin/env bash
set -e
echo "Post Installation Task For Kerberos - Cloudera Manager server"

yum install -y openldap-clients krb5-workstation 
mkdir /tmp/jce
cd /tmp/jce
wget http://10.0.10.251/repo/java/JCEPolicyJDK7/US_export_policy.jar
wget http://10.0.10.251/repo/java/JCEPolicyJDK7/local_policy.jar
mv /usr/java/jdk1.7.0_67-cloudera/jre/lib/security/local_policy.jar /usr/java/jdk1.7.0_67-cloudera/jre/lib/security/local_policy.jar.orig
mv /usr/java/jdk1.7.0_67-cloudera/jre/lib/security/US_export_policy.jar /usr/java/jdk1.7.0_67-cloudera/jre/lib/security/US_export_policy.jar.orig
cp /tmp/jce/local_policy.jar /usr/java/jdk1.7.0_67-cloudera/jre/lib/security/local_policy.jar
cp /tmp/jce/US_export_policy.jar /usr/java/jdk1.7.0_67-cloudera/jre/lib/security/US_export_policy.jar

cat > /etc/krb5.conf <<"EOF"
[logging]
 default = FILE:/var/log/krb5libs.log
 kdc = FILE:/var/log/krb5kdc.log
 admin_server = FILE:/var/log/kadmind.log

[libdefaults]
 default_realm = COMPUTE.INTERNAL
 dns_lookup_realm = false
 dns_lookup_kdc = false
 ticket_lifetime = 24h
 renew_lifetime = 7d
 forwardable = true

[realms]
 COMPUTE.INTERNAL = {
  kdc = kdcserver.compute.internal
  admin_server = kdcserver.compute.internal
 }

[domain_realm]
 .compute.internal = COMPUTE.INTERNAL
 compute.internal = COMPUTE.INTERNAL

EOF

#wget http://10.0.10.251/repo/kdc/cmf.keytab
#mv cmf.keytab /etc/cloudera-scm-server/
#chown cloudera-scm:cloudera-scm /etc/cloudera-scm-server/cmf.keytab
#chmod 600 /etc/cloudera-scm-server/cmf.keytab

#echo "cloudera-scm/admin@COMPUTE.INTERNAL" > /etc/cloudera-scm-server/cmf.principal
#chown cloudera-scm:cloudera-scm /etc/cloudera-scm-server/cmf.principal
#chmod 600 /etc/cloudera-scm-server/cmf.principal
