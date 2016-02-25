class compute_node(
  String $ovs_external_ip,
  String $manage_ip )
{

  include ::password
  package{'centos-release-openstack-liberty':
    ensure => present,
  }
  class{ 'compute_node::nova': 
    manage_ip => $manage_ip,
  }
  class{ 'compute_node::neutron':
    external_ip => $ovs_external_ip
  }
}
