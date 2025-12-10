# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :mdm_service_link, :class => 'Mdm::ServiceLink' do
    association :parent, :factory => :mdm_service
    association :child, :factory => :mdm_service
  end
end
