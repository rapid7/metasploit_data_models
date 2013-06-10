FactoryGirl.define do
  factory :mdm_module_relationship, :class => Mdm::Module::Relationship do
    association :descendant, :factory => :mdm_module_class
    association :ancestor, :factory => :mdm_module_ancestor
  end
end