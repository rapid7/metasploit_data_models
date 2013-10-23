FactoryGirl.define do
  factory :mdm_reference,
          :class => Mdm::Reference,
          :traits => [
              :metasploit_model_reference
          ] do
    #
    # Associations
    #

    association :authority, :factory => :mdm_authority

    factory :obsolete_mdm_reference,
            :traits => [
                :obsolete_metasploit_model_reference
            ]

    factory :seeded_authority_mdm_reference do
      authority { generate :seeded_mdm_authority }
      # nil url so that it is derived using authority
      url { nil }
    end

    factory :url_mdm_reference,
            :traits => [
                :url_metasploit_model_reference
            ]
  end
end