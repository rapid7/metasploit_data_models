FactoryGirl.define do
  factory :mdm_module_action, :class => Mdm::ModuleAction do

  end

  sequence :mdm_module_action_name do |n|
    "Mdm::ModuleAction#name #{n}"
  end
end