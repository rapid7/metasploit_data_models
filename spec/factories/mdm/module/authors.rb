FactoryGirl.define do
  factory :mdm_module_author, :class => Mdm::Module::Author do
    association :author, :factory => :mdm_author
    association :module_instance, :factory => :mdm_module_instance

    factory :full_mdm_module_author do
      association :email_address, :factory => :mdm_email_address
    end
  end
end