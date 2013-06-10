FactoryGirl.define do
  factory :mdm_module_target, :class => Mdm::Module::Target do
    index { generate :mdm_module_target_index }
    name { generate :mdm_module_target_name }

    #
    # Associations
    #
    association :module_instance, :factory => :mdm_module_instance
  end

  sequence :mdm_module_target_index do |n|
    n
  end

  sequence :mdm_module_target_name do |n|
    "Mdm::Module::Target#name #{n}"
  end
end