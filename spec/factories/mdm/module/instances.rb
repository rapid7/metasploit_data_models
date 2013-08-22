FactoryGirl.define do
  factory :mdm_module_instance,
          :class => Mdm::Module::Instance,
          :traits => [
              :metasploit_model_module_instance
          ] do
    ignore do
      module_type { generate :metasploit_model_module_type }
    end

    #
    # Associations
    #

    module_class { FactoryGirl.create(:mdm_module_class, :module_type => module_type) }

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

    factory :full_mdm_module_instance do
      ignore do
        action_count {
          # only auxiliary modules have actions
          if module_class.derived_module_type == Metasploit::Model::Module::Type::AUX
            rand(2) + 1
          else
            0
          end
        }

        architecture_count {
          # Every module needs at least one architecture
          rand(Metasploit::Model::Architecture::ABBREVIATIONS.length - 1) + 1
        }

        author_count {
          # Every module needs at least one author
          rand(2) + 1
        }

        platform_count {
          # only exploit modules have platforms and they must have at least one platform
          if module_class.derived_module_type == Metasploit::Model::Module::Type::EXPLOIT
            rand(2) + 1
          else
            0
          end
        }

        reference_count {
          # a module can have 0 references
          rand(2)
        }

        target_count {
          # only exploit modules have targets and they must have at least one target
          if module_class.derived_module_type == Metasploit::Model::Module::Type::EXPLOIT
            rand(2) + 1
          else
            0
          end
        }
      end

      after(:create) do |module_instance, evaluator|
        default_names = [:action, :target]
        names = [:action, :architecture, :author, :platform, :reference, :target]

        names.each do |name|
          factory = "mdm_module_#{name}".to_sym
          count = evaluator.send("#{name}_count")
          list = FactoryGirl.create_list(
              factory,
              count,
              :module_instance => module_instance
          )

          if default_names.include? name
            module_instance.send("default_#{name}=", list.sample)
          end
        end

        # save module_instance to update default_*.
        module_instance.save!
      end

      factory :stanced_full_mdm_module_instance do
        ignore do
          module_type { generate :metasploit_model_module_instance_stanced_module_type }
        end
      end
    end
  end
end