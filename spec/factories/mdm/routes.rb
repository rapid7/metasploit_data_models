FactoryGirl.define do
  factory :mdm_route, :class => Mdm::Route do
    #
    # Associations
    #
    association :session, :factory => :mdm_session
  end
end