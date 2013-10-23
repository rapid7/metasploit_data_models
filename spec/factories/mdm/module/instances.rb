FactoryGirl.define do
  factory_by_attribute = {
      actions: :mdm_module_action,
      module_architectures: :mdm_module_architecture,
      module_platforms: :mdm_module_platform,
      module_references: :mdm_module_reference,
      targets: :mdm_module_target
  }

  factory :mdm_module_instance,
          :class => Mdm::Module::Instance,
          :traits => [
              :metasploit_model_module_instance
          ] do
    #
    # Associations
    #

    association :module_class, factory: :mdm_module_class

    #
    # Attributes
    #

    # must be explicit and not part of trait to ensure it is run after module_class is created.
    stance {
      if supports?(:stance)
        generate :metasploit_model_module_stance
      else
        nil
      end
    }

    # needs to be an after(:build) and not an after(:create) to ensure counted associations are populated before being
    # validated.
    after(:build) do |mdm_module_instance, evaluator|
      mdm_module_instance.module_authors = evaluator.module_authors_length.times.collect {
        FactoryGirl.build(:mdm_module_author, module_instance: mdm_module_instance)
      }

      module_class = mdm_module_instance.module_class

      # only attempt to build supported associations if the module_class is valid because supports depends on a valid
      # module_type and validating the module_class will derive module_type.
      if module_class && module_class.valid?
        factory_by_attribute.each do |attribute, factory|
          if mdm_module_instance.supports?(attribute)
            length = evaluator.send("#{attribute}_length")

            collection = length.times.collect {
              FactoryGirl.build(factory, module_instance: mdm_module_instance)
            }

            mdm_module_instance.send("#{attribute}=", collection)
          end
        end
      end
    end
  end
end