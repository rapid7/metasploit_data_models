FactoryGirl.define do
  factory :mdm_module_ref, :class => Mdm::ModuleRef do

  end

  sequence :mdm_module_ref_name do |n|
    "Mdm::ModuleRef#name #{n}"
  end
end