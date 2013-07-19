FactoryGirl.define do
  factory :mdm_author,
          :class => Mdm::Author,
          :traits => [
              :metasploit_model_author
          ]
end