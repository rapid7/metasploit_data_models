FactoryGirl.define do
  factory :mdm_service, :class => Mdm::Service do
    #
    # Associations
    #
    association :host, :factory => :mdm_host

    #
    # Attributes
    #
    port 4567
    proto 'snmp'
    state 'open'
  end

  factory :web_service, :parent => :mdm_service do
    proto 'tcp'
    name { FactoryGirl.generate(:web_service_name) }
    port { FactoryGirl.generate(:port) }
  end

  port_bits = 16
  port_limit = 1 << port_bits

  sequence :port do |n|
    n % port_limit
  end

  sequence :web_service_name, ['http', 'https'].cycle
  
end