FactoryGirl.define do
  factory :mdm_vuln_reference, :class => Mdm::VulnReference do
    association :reference, :factory => :mdm_reference
    association :vuln, :factory => :mdm_vuln
  end
end