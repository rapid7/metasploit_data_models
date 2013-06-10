FactoryGirl.define do
  factory :mdm_module_action, :class => Mdm::Module::Action do
    name { generate :mdm_module_action_name }

    #
    # Associations
    #
    association :module_instance, :factory => :mdm_module_instance
  end

  sequence :mdm_module_action_name do |n|
    "Mdm::Module::Action#name #{n}"
  end
end