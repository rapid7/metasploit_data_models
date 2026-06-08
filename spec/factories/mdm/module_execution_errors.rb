FactoryBot.define do
  factory :mdm_module_execution_error,
          aliases: [:module_execution_error],
          class: 'Mdm::ModuleExecutionError' do
    association :module_execution, factory: :mdm_module_execution

    lifecycle_phase { 'run' }
    occurred_at     { Time.now.utc }
    exception_class { 'RuntimeError' }
    message         { 'something went wrong' }
    failure_reason  { nil }
  end
end
