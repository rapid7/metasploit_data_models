FactoryGirl.define do
  factory :mdm_authority, :class => Mdm::Authority do
    abbreviation { generate :mdm_authority_abbreviation }

    factory :full_mdm_authority do
      summary { generate :mdm_authority_summary }
      url { generate :mdm_authority_url }
    end

    factory :obsolete_mdm_authority do
      obsolete { true }
    end
  end

  sequence :mdm_authority_abbreviation do |n|
    'MDM-AUTHORITY-#{n}'
  end

  sequence :mdm_authority_summary do |n|
    "Mdm::Authority #{n}"
  end

  sequence :mdm_authority_url do |n|
    "http://example.com/mdm/authority/#{n}"
  end
end