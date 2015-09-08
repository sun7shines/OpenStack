
yum install openstack-glance python-glanceclient

openstack-config --set /etc/glance/glance-api.conf database connection mysql://glance:glance@controller/glance

openstack-config --set /etc/glance/glance-registry.conf database connection mysql://glance:glance@controller/glance

openstack-config --set /etc/glance/glance-api.conf DEFAULT rpc_backend qpid

openstack-config --set /etc/glance/glance-api.conf DEFAULT qpid_hostname controller

mysql -u root -p

CREATE DATABASE glance;

GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'localhost' IDENTIFIED BY 'glance';

GRANT ALL PRIVILEGES ON glance.* TO 'glance'@'%' IDENTIFIED BY 'glance';

su -s /bin/sh -c "glance-manage db_sync" glance

keystone user-create --name=glance --pass=glance --email=glance@163.com

keystone user-role-add --user=glance --tenant=service --role=admin


openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_uri http://controller:5000

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_host controller

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken auth_port 35357

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken  auth_protocol http

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken admin_tenant_name service

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken admin_user glance

openstack-config --set /etc/glance/glance-api.conf keystone_authtoken admin_password glance

openstack-config --set /etc/glance/glance-api.conf paste_deploy flavor keystone


openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken  auth_uri http://controller:5000


openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_host controller


openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_port 35357


openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken auth_protocol http


openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken admin_tenant_name service


openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken admin_user glance


openstack-config --set /etc/glance/glance-registry.conf keystone_authtoken admin_password glance 

openstack-config --set /etc/glance/glance-registry.conf paste_deploy flavor keystone







keystone service-create --name=glance --type=image --description="OpenStack Image Service"

keystone endpoint-create --service-id=$(keystone service-list | awk '/ image / {print $2}') --publicurl=http://controller:9292 --internalurl=http://controller:9292 --adminurl=http://controller:9292

service openstack-glance-api start
service openstack-glance-registry start
chkconfig openstack-glance-api on
chkconfig openstack-glance-registry on

mkdir /tmp/images
cd /tmp/images/
wget http://download.cirros-cloud.net/0.3.2/cirros-0.3.2-x86_64-disk.img

source admin-openrc.sh

glance image-create --name "cirros-0.3.2-x86_64" --disk-format qcow2 --container-format bare --is-public True --progress < cirros-0.3.2-x86_64-disk.img

###  glance image-create --name=IMAGELABEL --disk-format=FILEFORMAT --container-format=CONTAINERFORMAT --is-public=ACCESSVALUE < IMAGEFILE

glance image-list



