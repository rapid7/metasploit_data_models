FactoryGirl.define do
  factory :mdm_api_key, :class => Mdm::ApiKey do
    token { generate :mdm_api_key_token }
  end

  sequence :mdm_api_key_token do |n|
    "%08d" % n
  end
end