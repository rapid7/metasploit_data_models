FactoryGirl.define do
  factory :mdm_module_mixin, :class => Mdm::ModuleMixin do

  end

  sequence :mdm_module_mixin_name do |n|
    "Mdm::ModuleMixin#name #{n}"
  end
end