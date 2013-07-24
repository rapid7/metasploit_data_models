FactoryGirl.define do
  factory :mdm_platform,
          :class => Mdm::Platform,
          :traits => [
              :metasploit_model_platform
          ]
end