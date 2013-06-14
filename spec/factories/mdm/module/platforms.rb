FactoryGirl.define do
  factory :mdm_module_platform, :class => Mdm::Module::Platform do
    #
    # Associations
    #
    association :module_instance, :factory => :mdm_module_instance
    association :platform, :factory => :mdm_platform
  end
end