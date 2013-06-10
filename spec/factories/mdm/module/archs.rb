FactoryGirl.define do
  factory :mdm_module_arch, :class => Mdm::Module::Arch do
    name { generate :mdm_module_arch_name }

    #
    # Associations
    #
    association :module_instance, :factory => :mdm_module_instance
  end

  sequence :mdm_module_arch_name do |n|
    "Mdm::Module::Arch#name #{n}"
  end
end