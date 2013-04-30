FactoryGirl.define do
  factory :mdm_host, :class => Mdm::Host do
    #
    # Associations
    #
    association :workspace, :factory => :mdm_workspace

    #
    # Attributes
    #
    address { generate :mdm_ipv4_address }
    name { generate :mdm_host_name }
  end

  trait :server do
    mac "00:0c:29:8d:ec:99"
    state "Alive"
    os_lang "English"
    purpose "server"
  end

  sequence :mdm_host_name do |n|
    "mdm_host_#{n}"
  end
  
  sequence :windows_flavors, %w[NT XP 7 2008].cycle
  
  trait :windows do
    os_name "Windows"
    os_flavor { generate :windows_flavors }
  end
  
  sequence :linux_flavors, %w[Debian Ubuntu CentOS].cycle
  trait :linux do
    os_name "Linux"
    os_flavor { generate :linux_flavors }
  end
  
  trait :os_x do
    os_name "Mac OS X"
  end
  
end