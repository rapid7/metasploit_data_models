FactoryGirl.define do
  factory :mdm_module_target,
          :class => Mdm::Module::Target,
          :traits => [
              :metasploit_model_module_target
          ] do
    #
    # Associations
    #
    association :module_instance, :factory => :mdm_module_instance
  end
end
