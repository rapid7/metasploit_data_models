FactoryBot.define do
  factory :mdm_session, :aliases => [:session], :class => Mdm::Session do
    #
    # Associations
    #
    association :host, :factory => :mdm_host
    association :originating_module_run, :factory => :metasploit_data_models_module_run

    #
    # Attributes
    #
    opened_at { DateTime.now }
  end
end
