class compute_node::nova( String $manage_ip,
$controller_host = 'controller' )
{
  
  class{ 'nova':
    rabbit_host => "${controller_host}-int",
    rabbit_userid => 'openstack',
    rabbit_password => $::password::rabbit,
    glance_api_servers => "${controller_host}-int:9292"
  }
  
  class{ 'nova::compute':
    vncserver_proxyclient_address => $manage_ip,
    vncproxy_host => "${controller_host}.cloud.csie.ntu.edu.tw",
    vncproxy_protocol => 'http'
  }

  class{ 'nova::compute::libvirt':
    require => Class['neutron::agents::ml2::ovs'],
    libvirt_inject_key => true,
    vncserver_listen => '0.0.0.0',
  }
  
  class{ 'nova::network::neutron':
    neutron_admin_password => $::password::neutron,    
    neutron_url => "http://${controller_host}-int:9696",
    neutron_admin_auth_url => "http://${controller_host}-admin:35357/v2.0"
  }

}
  
  
