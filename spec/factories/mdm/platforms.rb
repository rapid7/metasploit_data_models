FactoryGirl.define do
  factory :mdm_platform, :class => Mdm::Platform do
    name { generate :mdm_platform_name }
  end

  sequence :mdm_platform_name do |n|
    "Mdm::Platform#name #{n}"
  end
end