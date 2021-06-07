FactoryBot.define do
  factory :mdm_vuln_ref, :class => Mdm::VulnRef do
    association :ref, factory: :mdm_ref
    association :vuln, factory: :mdm_vuln
  end
end
