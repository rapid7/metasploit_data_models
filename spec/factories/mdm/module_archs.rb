FactoryGirl.define do
  factory :mdm_module_archs, :class => Mdm::ModuleArch do

  end

  sequence :mdm_module_arch_name do |n|
    "Mdm::ModuleArch#name #{n}"
  end
end