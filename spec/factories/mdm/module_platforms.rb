FactoryGirl.define do
  factory :mdm_module_platform, :class => Mdm::ModulePlatform do

  end

  sequence :mdm_module_platform_name do |n|
    "Mdm::ModulePlatform#name #{n}"
  end
end