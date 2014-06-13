FactoryGirl.define do
  factory :mdm_cred, :aliases => [:cred], :class => Mdm::Cred do
    #
    # Associations
    #
    association :service, :factory => :mdm_service
  end
end