FactoryGirl.define do
  factory :mdm_module_action, :class => Mdm::ModuleAction do
    name { generate :mdm_module_action_name }

    #
    # Associations
    #
    association :module_detail, :factory => :mdm_module_detail
  end

  sequence :mdm_module_action_name do |n|
    "Mdm::ModuleAction#name #{n}"
  end
end