FactoryGirl.define do
  factory :mdm_module_arch, :class => Mdm::ModuleArch do
    name { generate :mdm_module_arch_name }

    #
    # Associations
    #
    association :module_detail, :factory => :mdm_module_detail
  end

  sequence :mdm_module_arch_name do |n|
    "Mdm::ModuleArch#name #{n}"
  end
end