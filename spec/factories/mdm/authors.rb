FactoryGirl.define do
  factory :mdm_author, :class => Mdm::Author do
    name { generate :mdm_author_name }
  end

  sequence :mdm_author_name do |n|
    "Author #{n}"
  end
end