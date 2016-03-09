class compute_node::neutron( $external_ip, $controller_host = 'controller3' ) {

  service { 'NetworkManager':
    ensure => stopped
  }

    
  class { 'neutron':
    verbose         => true,
    debug           => false,
    rabbit_host => "${controller_host}-int",
    rabbit_user => 'openstack',
    rabbit_password => $::password::rabbit,
    lock_path => '/var/lib/neutron/tmp',    
  }    
  
  # ml2 plugin with vxlan as ml2 driver and ovs as mechanism driver
  class { '::neutron::plugins::ml2':
    type_drivers         => ['vxlan', 'flat', 'vlan'],
    tenant_network_types => ['vxlan'],
    vxlan_group          => '239.1.1.1',
    mechanism_drivers    => ['openvswitch', 'l2population'],
    vni_ranges           => '1:1000'
  }

  vs_bridge{ 'br-int':
    ensure => present
  }~>
  
  class { 'neutron::agents::ml2::ovs':
    subscribe => Class['::network_config'],
    bridge_mappings => ['external:br-ext'],
    bridge_uplinks => ['br-ext:em3','br-int:em2'],
    enable_tunneling => true,
    tunnel_types => ['vxlan'],
    local_ip => $external_ip,
    l2_population => true,
    arp_responder => true,
    enable_distributed_routing => true  
  }

  class { 'neutron::agents::dhcp':
    subscribe => Class['neutron::agents::ml2::ovs'],
  }

  class { 'neutron::agents::l3':
    subscribe => Class['neutron::agents::ml2::ovs'],
    debug => true,
    use_namespaces => true,
    external_network_bridge => '',
    router_delete_namespaces => true,
    agent_mode => 'dvr'
  }

  
}
