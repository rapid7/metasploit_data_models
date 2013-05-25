FactoryGirl.define do
  factory :mdm_event, :class => Mdm::Event do
    #
    # Associations
    #
    association :host, :factory => :mdm_host

  end
end