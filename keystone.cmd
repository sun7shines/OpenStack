一 1
yum install openstack-keystone python-keystoneclient

2
openstack-config --set /etc/keystone/keystone.conf  database connection mysql://keystone:keystone@localhost/keystone


3

/etc/init.d/mysqld restart

chkconfig mysqld on

mysql -u root -p
mysql> CREATE DATABASE keystone;
mysql> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'localhost' IDENTIFIED BY 'keystone';
mysql> GRANT ALL PRIVILEGES ON keystone.* TO 'keystone'@'%' IDENTIFIED BY 'keystone';
mysql> exit

4
su -s /bin/sh -c "keystone-manage db_sync" keystone

5
# ADMIN_TOKEN=$(openssl rand -hex 10)
# echo $ADMIN_TOKEN

openstack-config --set /etc/keystone/keystone.conf DEFAULT admin_token 136d104290d2d874eb07 

6

keystone-manage pki_setup --keystone-user keystone --keystone-group keystone
chown -R keystone:keystone /etc/keystone/ssl
chmod -R o-rwx /etc/keystone/ssl


7
service openstack-keystone start
chkconfig openstack-keystone on


8

(crontab -l -u keystone 2>&1 | grep -q token_flush) || echo '@hourly /usr/bin/keystone-manage token_flush >/var/log/keystone/keystone-tokenflush.log 2>&1' >> /var/spool/cron/keystone

-------------------------------------

二  create admin user

export OS_SERVICE_TOKEN=136d104290d2d874eb07
export OS_SERVICE_ENDPOINT=http://localhost:35357/v2.0

步骤 1 2 3 4 5
keystone user-create --name=admin --pass=admin --email=admin@163.com

keystone role-create --name=admin

keystone tenant-create --name=admin --description="Admin Tenant"

keystone user-role-add --user=admin --tenant=admin --role=admin

keystone user-role-add --user=admin --role=_member_ --tenant=admin


三 create nomal user

1.
keystone user-create --name=demo --pass=demo --email=demo@163.com ;keystone tenant-create --name=demo --description="Demo Tenant" ;keystone user-role-add --user=demo --role=_member_ --tenant=demo

###  keystone user-role-add --user=demo --role=SwiftOperator --tenant=demo


###  keystone endpoint-create --service-id=$(keystone service-list | awk '/ object-store / {print $2}') --publicurl='http://localhost:8080/v1/AUTH_53438b9f9a6641b1a55ec237b53183e1' --internalurl='http://localhost:8080/v1/AUTH_53438b9f9a6641b1a55ec237b53183e1' --adminurl=http://localhost:8080

四 create service tenant
keystone tenant-create --name=service --description="Service Tenant"


五 define services and api endpoints

keystone service-create --name=keystone --type=identity --description="OpenStack Identity"

keystone endpoint-create --service-id=$(keystone service-list | awk '/ identity / {print $2}') --publicurl=http://localhost:5000/v2.0 --internalurl=http://localhost:5000/v2.0 --adminurl=http://localhost:35357/v2.0


六 verify the identity service installtion

步骤 1 2 3 4 5  6 7

1 unset OS_SERVICE_TOKEN OS_SERVICE_ENDPOINT

2 keystone --os-username=admin --os-password=admin --os-auth-url=http://localhost:35357/v2.0 token-get

3 keystone --os-username=admin --os-password=admin --os-tenant-name=admin --os-auth-url=http://localhost:35357/v2.0 token-get

4 
export OS_USERNAME=admin
export OS_PASSWORD=admin
export OS_TENANT_NAME=admin
export OS_AUTH_URL=http://localhost:35357/v2.0

5 source admin-openrc.sh

6 keystone token-get

7 keystone user-list


keystone --os-username=demo --os-password=demo --os-tenant-name=demo --os-auth-url=http://localhost:35357/v2.0 token-get


