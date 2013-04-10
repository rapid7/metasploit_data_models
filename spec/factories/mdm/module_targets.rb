FactoryGirl.define do
  factory :mdm_module_target, :class => Mdm::ModuleTarget do

  end

  sequence :mdm_module_target_index do |n|
    n
  end

  sequence :mdm_module_target_name do |n|
    "Mdm::ModuleTarget#name #{n}"
  end
end