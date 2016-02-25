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

  class { 'neutron::agents::dhcp':
  }

  class { 'neutron::agents::l3':
    debug => true,
    use_namespaces => true,
    external_network_bridge => '',
    router_delete_namespaces => true,
    agent_mode => 'dvr'
  }

  class { 'neutron::agents::ml2::ovs':
    bridge_mappings => ['external:br-ext'],
    enable_tunneling => true,
    tunnel_types => ['vxlan'],
    local_ip => $external_ip,
    l2_population => true,
    arp_responder => true,
    enable_distributed_routing => true  
  }
  
}
