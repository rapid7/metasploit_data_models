# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mdm_task_service, :class => 'Mdm::TaskService' do
    association :task, :factory => :mdm_task
    association :service, :factory => :mdm_service
  end
end
