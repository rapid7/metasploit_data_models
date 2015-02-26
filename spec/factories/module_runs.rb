FactoryGirl.define do
  sequence(:session_id)

  factory :module_run, class: MetasploitDataModels::ModuleRun do

    association :user, factory: :mdm_user

    trait :failed do
      status MetasploitDataModels::ModuleRun::FAIL
    end

    trait :exploited do
      status MetasploitDataModels::ModuleRun::SUCCEED
    end

    trait :error do
      status MetasploitDataModels::ModuleRun::ERROR
    end

    attempted_at Time.now
    session_id 1
    port { generate(:port) }
    proto "http"
    fail_detail "Failed to execute payload froamasher"
    status MetasploitDataModels::ModuleRun::SUCCEED
    username "joefoo"
    module_full_name "exploit/windows/happy-stack-smasher"
  end
end

