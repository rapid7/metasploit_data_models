FactoryGirl.define do
  factory :mdm_module_action,
          :class => Mdm::Module::Action,
          :traits => [
              :metasploit_model_module_action
          ] do
    #
    # Associations
    #
    association :module_instance, :factory => :mdm_module_instance
  end
end