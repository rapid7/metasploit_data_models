FactoryGirl.define do
  factory :mdm_module_architecture, :class => Mdm::Module::Architecture do
    #
    # Associations
    #

    architecture { generate :mdm_architecture }
    association :module_instance, :factory => :mdm_module_instance
  end
end