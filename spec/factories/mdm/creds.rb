FactoryGirl.define do
  factory :mdm_cred, :aliases => [:cred], :class => Mdm::Cred do
    #
    # Associations
    #

    association :service, :factory => :mdm_service

    factory :full_mdm_cred do
      #
      # Attributes
      #

      active { generate :mdm_cred_active }
      pass { generate :mdm_cred_pass }
      proof { generate :mdm_cred_proof }
      ptype { generate :mdm_cred_ptype }
      user { generate :mdm_cred_user }

      # TODO creds.source_id and creds.source_type exists, but there is no sources association.
    end
  end

  sequence :mdm_cred_active, [false, true].cycle

  sequence :mdm_cred_pass do |n|
    "Mdm::Cred#pass#{n}"
  end

  sequence :mdm_cred_proof do |n|
    "Mdm::Cred#proof #{n}"
  end

  ptypes = Mdm::Cred::HUMAN_PTYPE_BY_PTYPE.keys
  sequence :mdm_cred_ptype, ptypes.cycle

  sequence :mdm_cred_user do |n|
    "Mdm::Cred#user#{n}"
  end
end