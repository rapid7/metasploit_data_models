FactoryBot.define do
  factory :mdm_module_execution_event,
          aliases: [:module_execution_event],
          class: 'Mdm::ModuleExecutionEvent' do
    association :module_execution, factory: :mdm_module_execution

    sequence(:name) { |n| "milestone_#{n}" }
    payload     { {} }
    occurred_at { Time.now.utc }
  end
end
