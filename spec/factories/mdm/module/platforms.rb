FactoryGirl.define do
  factory :mdm_module_platform, :class => Mdm::Module::Platform do
    name { generate :mdm_module_platform_name }

    #
    # Associations
    #
    association :module_instance, :factory => :mdm_module_instance
  end

  sequence :mdm_module_platform_name do |n|
    "Mdm::Module::Platform#name #{n}"
  end
end