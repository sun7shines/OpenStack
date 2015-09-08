controller node:

yum install openstack-nova-api openstack-nova-cert openstack-nova-conductor openstack-nova-console openstack-nova-novncproxy openstack-nova-scheduler python-novaclient

openstack-config --set /etc/nova/nova.conf database connection mysql://nova:nova@controller/nova

openstack-config --set /etc/nova/nova.conf DEFAULT rpc_backend qpid

openstack-config --set /etc/nova/nova.conf DEFAULT qpid_hostname controller

openstack-config --set /etc/nova/nova.conf DEFAULT my_ip 192.168.36.211 

openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_listen 192.168.36.211 

openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address 192.168.36.211 


mysql -u root -p

CREATE DATABASE nova;

GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'localhost' IDENTIFIED BY 'nova';

GRANT ALL PRIVILEGES ON nova.* TO 'nova'@'%' IDENTIFIED BY 'nova';

su -s /bin/sh -c "nova-manage db sync" nova

keystone user-create --name=nova --pass=nova --email=nova@163.com

keystone user-role-add --user=nova --tenant=service --role=admin


openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone

openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_uri http://controller:5000

openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_host controller


openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_protocol http


openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_port 35357


openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_user nova


openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_tenant_name service


openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_password nova 




keystone service-create --name=nova --type=compute --description="OpenStack Compute"

$ keystone endpoint-create --service-id=$(keystone service-list | awk '/ compute / {print $2}') --publicurl=http://controller:8774/v2/%\(tenant_id\)s --internalurl=http://controller:8774/v2/%\(tenant_id\)s --adminurl=http://controller:8774/v2/%\(tenant_id\)s


service openstack-nova-api start
service openstack-nova-cert start
service openstack-nova-consoleauth start
service openstack-nova-scheduler start
service openstack-nova-conductor start
service openstack-nova-novncproxy start
chkconfig openstack-nova-api on
chkconfig openstack-nova-cert on
chkconfig openstack-nova-consoleauth on
chkconfig openstack-nova-scheduler on
chkconfig openstack-nova-conductor on
chkconfig openstack-nova-novncproxy on


nova image-list



COMPUTE NODE


yum install openstack-nova-compute


openstack-config --set /etc/nova/nova.conf database connection mysql://nova:nova@controller/nova


openstack-config --set /etc/nova/nova.conf DEFAULT auth_strategy keystone


openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_uri http://controller:5000


openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_host controller


openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_protocol http


openstack-config --set /etc/nova/nova.conf keystone_authtoken auth_port 35357


openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_user nova


openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_tenant_name service


openstack-config --set /etc/nova/nova.conf keystone_authtoken admin_password nova


openstack-config --set /etc/nova/nova.conf DEFAULT rpc_backend qpid

openstack-config --set /etc/nova/nova.conf DEFAULT qpid_hostname controller


openstack-config --set /etc/nova/nova.conf DEFAULT my_ip 192.168.36.212 

openstack-config --set /etc/nova/nova.conf DEFAULT vnc_enabled True

openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_listen 0.0.0.0

openstack-config --set /etc/nova/nova.conf DEFAULT vncserver_proxyclient_address 192.168.36.212 

openstack-config --set /etc/nova/nova.conf DEFAULT novncproxy_base_url http://controller:6080/vnc_auto.html

openstack-config --set /etc/nova/nova.conf DEFAULT glance_host controller


egrep -c '(vmx|svm)' /proc/cpuinfo


openstack-config --set /etc/nova/nova.conf libvirt virt_type qemu

service libvirtd start
service messagebus start
service openstack-nova-compute start
chkconfig libvirtd on
chkconfig messagebus on
chkconfig openstack-nova-compute on





