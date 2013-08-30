FactoryGirl.define do
  factory :mdm_authority,
          :class => Mdm::Authority,
          :traits => [
              :metasploit_model_authority
          ] do
    factory :full_mdm_authority,
            :traits => [
                :full_metasploit_model_authority
            ]

    factory :obsolete_mdm_authority,
            :traits => [
                :obsolete_metasploit_model_authority
            ]
  end

  seeded_abbreviations = [
      'BID',
      'CVE',
      'MIL',
      'MSB',
      'OSVDB',
      'PMASA',
      'SECUNIA',
      'US-CERT-VU',
      'waraxe'
  ]
  seeded_abbreviation_count = seeded_abbreviations.length

  sequence :seeded_mdm_authority do |n|
    abbreviation = seeded_abbreviations[n % seeded_abbreviation_count]

    Mdm::Authority.where(:abbreviation => abbreviation).first
  end
end