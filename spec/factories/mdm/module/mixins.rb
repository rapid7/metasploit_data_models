FactoryGirl.define do
  factory :mdm_module_mixin, :class => Mdm::Module::Mixin do
    name { generate :mdm_module_mixin_name }

    #
    # Associations
    #
    association :module_instance, :factory => :mdm_module_instance
  end

  sequence :mdm_module_mixin_name do |n|
    "Mdm::Module::Mixin#name #{n}"
  end
end