FactoryGirl.define do
  factory :mdm_module_mixin, :class => Mdm::ModuleMixin do
    name { generate :mdm_module_mixin_name }

    #
    # Associations
    #
    association :module_detail, :factory => :mdm_module_detail
  end

  sequence :mdm_module_mixin_name do |n|
    "Mdm::ModuleMixin#name #{n}"
  end
end