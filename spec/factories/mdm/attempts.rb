FactoryGirl.define do
  sequence :mdm_attempt_attempted_at do |n|
    Time.now.utc - n.minutes
  end

  boolean = [false, true]
  sequence :mdm_attempt_exploited, boolean.cycle

  sequence :mdm_attempt_username do |n|
    "mdm.attempt.username.#{n}"
  end

  trait :mdm_attempt do
    attempted_at { generate :mdm_attempt_attempted_at }
    exploited { generate :mdm_attempt_exploited }

    association :module_class, factory: :mdm_module_class
    association :vuln, factory: :mdm_vuln
    username { generate :mdm_attempt_username }
  end
end