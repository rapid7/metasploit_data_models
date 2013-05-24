# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :mdm_task_cred, :class => 'Mdm::TaskCred' do

    association :task, :factory => :mdm_task
    association :cred, :factory => :mdm_cred
  end
end
