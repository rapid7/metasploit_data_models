FactoryGirl.define do
  factory :mdm_module_instance, :class => Mdm::Module::Instance do
    #
    # Associations
    #

    association :module_class, :factory => :mdm_module_class
  end
end