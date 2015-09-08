一 1 2 3 4 5 

1
keystone user-create --name=swift --pass=swift --email=swift@163.com

keystone user-role-add --user=swift --tenant=service --role=admin


2 

keystone service-create --name=swift --type=object-store --description="OpenStack Object Storage"

3

keystone endpoint-create --service-id=$(keystone service-list | awk '/ object-store / {print $2}') --publicurl='http://controller:8080/v1/AUTH_%(tenant_id)s' --internalurl='http://controller:8080/v1/AUTH_%(tenant_id)s' --adminurl=http://controller:8080


###  keystone endpoint-create --service-id=$(keystone service-list | awk '/ object-store / {print $2}') --publicurl='http://controller:8080/v1/AUTH_53438b9f9a6641b1a55ec237b53183e1' --internalurl='http://controller:8080/v1/AUTH_53438b9f9a6641b1a55ec237b53183e1' --adminurl=http://controller:8080

###  keystone endpoint-create --region myregion --service_id 5877e3bab9144df08bf554f16fc47ff3 --publicurl 'http://localhost:8080/v1/AUTH_9b154b36eba44e6faa243cbe31cd505e' --adminurl 'http://localhost:8080/v1' --internalurl 'http://localhost:8080/v1/AUTH_9b154b36eba44e6faa243cbe31cd505e

4
mkdir -p /etc/swift


5

一 所有的节点
/etc/swift/swift.conf

[swift-hash]
# random unique string that can never change (DO NOT LOSE)
swift_hash_path_prefix = xrfuniounenqjnw
swift_hash_path_suffix = fLIbertYgibbitZ


二 Install and configure storage nodes
1 yum install openstack-swift-account openstack-swift-container openstack-swift-object xfsprogs xinetd

2
fdisk /dev/sdb
mkfs.xfs /dev/sdb1
echo "/dev/sdb1 /srv/node/sdb1 xfs noatime,nodiratime,nobarrier,logbufs=0 0" >> /etc/fstab
mkdir -p /srv/node/sdb1
mount /srv/node/sdb1
chown -R swift:swift /srv/node


3 
vim /etc/rsyncd.conf

uid = swift
gid = swift
log file = /var/log/rsyncd.log
pid file = /var/run/rsyncd.pid
address = 192.168.36.201 / 192.168.36.202 

[account]
max connections = 2
path = /srv/node/
read only = false
lock file = /var/lock/account.lock
[container]
max connections = 2
path = /srv/node/
read only = false
lock file = /var/lock/container.lock
[object]
max connections = 2
path = /srv/node/
read only = false
lock file = /var/lock/object.lock

4 
～～～～

5 
vim  /etc/xinetd.d/rsync
disable = no

6
service xinetd start

7 

mkdir -p /var/swift/recon
chown -R swift:swift /var/swift/recon




三 install and configure the proxy node

1
 yum install openstack-swift-proxy memcached python-swiftclient python-keystone-auth-token

2 

vim /etc/sysconfig/memcached

OPTIONS="-l 192.168.36.200"

3 

service memcached start
chkconfig memcached on

4

vim /etc/swift/proxy-server.conf

[DEFAULT]
bind_port = 8080
user = swift

[pipeline:main]
pipeline = healthcheck cache authtoken keystoneauth proxy-server

[app:proxy-server]
use = egg:swift#proxy
allow_account_management = true
account_autocreate = true

[filter:keystoneauth]
use = egg:swift#keystoneauth
operator_roles = Member,admin,swiftoperator

[filter:authtoken]
paste.filter_factory = keystoneclient.middleware.auth_token:filter_factory

# Delaying the auth decision is required to support token-less
# usage for anonymous referrers ('.r:*').
delay_auth_decision = true
# auth_* settings refer to the Keystone server
auth_protocol = http
auth_host = controller
auth_port = 35357
# the service tenant and swift username and password created in Keystone
admin_tenant_name = service
admin_user = swift
admin_password = swift 

[filter:cache]
use = egg:swift#memcache

[filter:catch_errors]
use = egg:swift#catch_errors

[filter:healthcheck]
use = egg:swift#healthcheck

5 

cd /etc/swift
swift-ring-builder account.builder create 18 3 1
swift-ring-builder container.builder create 18 3 1
swift-ring-builder object.builder create 18 3 1

6 
swift-ring-builder account.builder add z1-192.168.36.211:6002/sdb1 100
swift-ring-builder container.builder add z1-192.168.36.211:6001/sdb1 100
swift-ring-builder object.builder add z1-192.168.36.211:6000/sdb1 100


swift-ring-builder account.builder add z1-192.168.36.201:6002R192.168.36.202:6005/sdb1 100
swift-ring-builder container.builder add z1-192.168.36.201:6001R192.168.36.202:6004/sdb1 100
swift-ring-builder object.builder add z1-192.168.36.201:6000R192.168.36.202:6003/sdb1 100

swift-ring-builder account.builder add z1-192.168.36.202:6002R192.168.36.201:6005/sdb1 100
swift-ring-builder container.builder add z1-192.168.36.202:6001R192.168.36.201:6004/sdb1 100
swift-ring-builder object.builder add z1-192.168.36.202:6000R192.168.36.201:6003/sdb1 100

7

swift-ring-builder account.builder
swift-ring-builder container.builder
swift-ring-builder object.builder

8

swift-ring-builder account.builder rebalance
swift-ring-builder container.builder rebalance
swift-ring-builder object.builder rebalance

9

copy account.ring.gz, container.ring.gz, and object.ring.gz to storage nodes

10

chown -R swift:swift /etc/swift

11

service openstack-swift-proxy start
chkconfig openstack-swift-proxy on

 
四 Start services on the storage nodes
1

for service in openstack-swift-object openstack-swift-object-replicator openstack-swift-object-updater openstack-swift-object-auditor openstack-swift-container openstack-swift-container-replicator openstack-swift-container-updater openstack-swift-container-auditor openstack-swift-account openstack-swift-account-replicator openstack-swift-account-reaper openstack-swift-account-auditor; do service $service start; chkconfig $service on; done

2 

swift-init all start






添加swift用户

keystone user-create --name=swift1 --pass=swift1 --email=swift1@163.com

keystone user-create --name=swift1 --pass=swift1 --email=swift1@163.com

source admin-openrc.sh

keystone user-role-add --user=swift1 --tenant=service --role=admin


WEB管理。需要以service/admin 的方式去创建user4

swift stat --os-username=user4 --os-password=user4 --os-tenant-name=service

或者修改role的配置 proxy-server.conf 

operator_roles = Member,admin, _member_,SwiftOperator ，创建Member 角色，或者_member_角色。

swift stat --os-username=upro1 --os-password=upro1 --os-tenant-name=pro1

