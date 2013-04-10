FactoryGirl.define do
  factory :mdm_module_author, :class => Mdm::ModuleAuthor do
    name { generate :mdm_module_author_name }

    #
    # Associations
    #
    association :module_detail, :factory => :mdm_module_detail

    factory :full_mdm_module_author do
      email { generate :mdm_module_author_name }
    end
  end

  sequence :mdm_module_author_name do |n|
    "Mdm::ModuleAuthor#name #{n}"
  end

  sequence :mdm_module_author_email do |n|
    "Mdm::ModuleAuthor#email #{n}"
  end
end