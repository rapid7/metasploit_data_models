FactoryGirl.define do
  factory :mdm_email_address, :class => Mdm::EmailAddress do
    domain { generate :mdm_email_address_domain }
    local { generate :mdm_email_address_local }
  end

  sequence :mdm_email_address_domain do |n|
    "mdm-email-address-domain#{n}.com"
  end

  sequence :mdm_email_address_local do |n|
    "mdm.email.address.local+#{n}"
  end
end