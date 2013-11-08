FactoryGirl.define do
  factory_by_attribute = {
      actions: :mdm_module_action,
      module_references: :mdm_module_reference
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
      if stanced?
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
          if mdm_module_instance.allows?(attribute)
            length = evaluator.send("#{attribute}_length")

            collection = length.times.collect {
              FactoryGirl.build(factory, module_instance: mdm_module_instance)
            }

            mdm_module_instance.send("#{attribute}=", collection)
          end
        end

        # make sure targets are generated first so that module_architectures and module_platforms can be include
        # the targets' architectures and platforms.
        if mdm_module_instance.allows?(:targets)
          # factory adds built module_targets to module_instance.
          FactoryGirl.build_list(
              :mdm_module_target,
              evaluator.targets_length,
              module_instance: mdm_module_instance
          )
          # module_architectures and module_platforms will be derived from targets
        else
          # if there are no targets, then architectures and platforms need to be explicitly defined on module instance
          # since they can't be derived from anything
          [:architecture, :platform].each do |suffix|
            attribute = "module_#{suffix.to_s.pluralize}".to_sym

            if mdm_module_instance.allows?(attribute)
              factory = "mdm_module_#{suffix}"
              length = evaluator.send("#{attribute}_length")

              collection = FactoryGirl.build_list(
                  factory,
                  length,
                  module_instance: mdm_module_instance
              )
              mdm_module_instance.send("#{attribute}=", collection)
            end
          end
        end
      end
    end
  end
end