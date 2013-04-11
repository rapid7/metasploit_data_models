FactoryGirl.define do
  factory :mdm_module_ref, :class => Mdm::ModuleRef do
    name { generate :mdm_module_ref_name }

    #
    # Associations
    #
    association :module_detail, :factory => :mdm_module_detail
  end

  sequence :mdm_module_ref_name do |n|
    "Mdm::ModuleRef#name #{n}"
  end
end