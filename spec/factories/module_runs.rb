FactoryGirl.define do
  factory :module_run do
    trackable_type "MyString"
    trackable_id 1
    attempted_at "2015-02-19 11:38:21"
    session_id 1
    port 1
    proto "MyString"
    fail_detail "MyText"
    status "MyString"
    username "MyString"
    user_id 1
    module_name "exploit/windows/happy-stack-smasher"
  end
end

