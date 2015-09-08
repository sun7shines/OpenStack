
controller node

openstack-config --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.api.API


openstack-config --set /etc/nova/nova.conf DEFAULT security_group_api nova


service openstack-nova-api restart
service openstack-nova-scheduler restart
service openstack-nova-conductor restart

COMPUTE NODE

yum install openstack-nova-network openstack-nova-api

openstack-config --set /etc/nova/nova.conf DEFAULT network_api_class nova.network.api.API


openstack-config --set /etc/nova/nova.conf DEFAULT security_group_api nova


openstack-config --set /etc/nova/nova.conf DEFAULT network_manager nova.network.manager.FlatDHCPManager


openstack-config --set /etc/nova/nova.conf DEFAULT firewall_driver nova.virt.libvirt.firewall.IptablesFirewallDriver


openstack-config --set /etc/nova/nova.conf DEFAULT network_size 254


openstack-config --set /etc/nova/nova.conf DEFAULT allow_same_net_traffic False


openstack-config --set /etc/nova/nova.conf DEFAULT multi_host True


openstack-config --set /etc/nova/nova.conf DEFAULT send_arp_for_ha True


openstack-config --set /etc/nova/nova.conf DEFAULT share_dhcp_address True


openstack-config --set /etc/nova/nova.conf DEFAULT force_dhcp_release True


openstack-config --set /etc/nova/nova.conf DEFAULT flat_network_bridge br100


openstack-config --set /etc/nova/nova.conf DEFAULT flat_interface eth2 


openstack-config --set /etc/nova/nova.conf DEFAULT public_interface eth2 


service openstack-nova-network start

service openstack-nova-metadata-api start

chkconfig openstack-nova-network on

chkconfig openstack-nova-metadata-api on



CONTROLLER NODE

source admin-openrc.sh

###  nova network-create demo-net --bridge br100 --multi-host T --fixed-range-v4 NETWORK_CIDR

nova network-create demo-net --bridge br100 --multi-host T --fixed-range-v4 203.0.113.24/29

