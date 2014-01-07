FactoryGirl.define do
  factory :mdm_session, :aliases => [:session], :class => Mdm::Session do
    #
    # Associations
    #
    exploit_class {
      FactoryGirl.create(
          :mdm_module_class,
          module_type: 'exploit'
      )
    }
    architecture { generate :mdm_architecture }
    association :host, :factory => :mdm_host
    payload_class {
      FactoryGirl.create(
          :mdm_module_class,
          module_type: 'payload'
      )
    }
    platform { generate :mdm_platform }

    #
    # Attributes
    #
    opened_at { DateTime.now }
  end
end