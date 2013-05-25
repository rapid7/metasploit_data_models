FactoryGirl.define do
  factory :mdm_event, :aliases => [:event], :class => Mdm::Event do
    name { FactoryGirl.generate :mdm_event_name }

    trait :workspace do
      association :workspace, :factory => :mdm_workspace
    end

    factory :mdm_workspace_event, :traits => [:workspace]
  end

  sequence :mdm_event_name do |n|
    "Event #{n}"
  end
end