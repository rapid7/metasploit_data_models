FactoryBot.define do
  factory :mdm_module_execution,
          aliases: [:module_execution],
          class: 'Mdm::ModuleExecution' do
    association :workspace, factory: :mdm_workspace

    sequence(:module_reference_name) { |n| "auxiliary/scanner/example_#{n}" }
    module_type    { 'auxiliary' }
    kind           { 'run' }
    originating_interface { 'console' }
    started_at     { Time.now.utc }
    terminal_status { 'running' }
    ended_at        { nil }
    single_entity_failure_count { 0 }
  end
end
