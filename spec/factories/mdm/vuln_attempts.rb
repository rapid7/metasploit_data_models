FactoryGirl.define do
  factory :mdm_vuln_attempt,
          class: Mdm::VulnAttempt,
          traits: [
              :mdm_attempt
          ]
end