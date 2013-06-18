FactoryGirl.define do
  factory :mdm_module_reference, :class => Mdm::Module::Reference do
    association :module_instance, :factory => :mdm_module_instance
    association :reference, :factory => :mdm_reference
  end
end