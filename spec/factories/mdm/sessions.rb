FactoryGirl.define do
  factory :mdm_session, :aliases => [:session], :class => Mdm::Session do
    #
    # Associations
    #
    association :host, :factory => :mdm_host
    architecture { generate :mdm_architecture }
    platform { generate :mdm_platform }

    #
    # Attributes
    #
    opened_at { DateTime.now }
  end
end