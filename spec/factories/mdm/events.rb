FactoryBot.define do
  factory :mdm_event, :aliases => [:event], :class => Mdm::Event do
    name { FactoryBot.generate :mdm_event_name }

    association :workspace, :factory => :mdm_workspace

    factory :mdm_workspace_event, :traits => [:workspace]
  end

  sequence :mdm_event_name do |n|
    "Event #{n}"
  end
end
