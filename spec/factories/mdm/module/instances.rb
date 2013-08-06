FactoryGirl.define do
  factory :mdm_module_instance,
          :class => Mdm::Module::Instance,
          :traits => [
              :metasploit_model_module_instance
          ] do
    #
    # Associations
    #

    association :module_class, :factory => :mdm_module_class

    #
    # Attributes
    #

    # must be explicit and not part of trait to ensure it is run after module_class is created.
    stance {
      if supports_stance?
        generate :metasploit_model_module_instance_stance
      else
        nil
      end
    }
  end
end