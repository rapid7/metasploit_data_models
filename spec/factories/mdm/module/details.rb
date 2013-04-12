FactoryGirl.define do
  factory :mdm_module_detail, :class => Mdm::Module::Detail do
    refname { generate :mdm_module_detail_refname }
  end

  sequence :mdm_module_detail_refname do |n|
    "module/ref/name#{n}"
  end
end