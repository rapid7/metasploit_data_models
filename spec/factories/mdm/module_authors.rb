FactoryGirl.define do
  factory :mdm_module_author, :class => Mdm::ModuleAuthor do

  end

  sequence :mdm_module_author_name do |n|
    "Mdm::ModuleAuthor#name #{n}"
  end

  sequence :mdm_module_author_email do |n|
    "Mdm::ModuleAuthor#email #{n}"
  end
end