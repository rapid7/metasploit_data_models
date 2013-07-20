FactoryGirl.define do
  factory :mdm_email_address,
          :class => Mdm::EmailAddress,
          :traits => [
              :metasploit_model_email_address
          ]
end