FactoryGirl.define do
  factory :mdm_module_platform, :class => Mdm::ModulePlatform do
    name { generate :mdm_module_platform_name }

    #
    # Associations
    #
    association :module_detail, :factory => :mdm_module_detail
  end

  sequence :mdm_module_platform_name do |n|
    "Mdm::ModulePlatform#name #{n}"
  end
end