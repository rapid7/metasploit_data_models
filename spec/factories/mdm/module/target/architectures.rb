FactoryGirl.define do
  factory :mdm_module_target_architecture,
          class: Mdm::Module::Target::Architecture do
    architecture { generate :mdm_architecture }
    association :module_target,
                factory: :mdm_module_target,
                strategy: :build,
                # disable module_target factory from building target_architectures since this factory is already
                # building one
                target_architectures_length: 0

    after(:build) do |module_target_architecture|
      module_target = module_target_architecture.module_target

      if module_target
        unless module_target.target_architectures.include? module_target_architecture
          module_target.target_architectures << module_target_architecture
        end

        architecture = module_target_architecture.architecture
        module_instance = module_target.module_instance

        if architecture && module_instance
          actual_architecture_set = module_instance.module_architectures.map(&:architecture)

          unless actual_architecture_set.include? architecture
            module_instance.module_architectures << FactoryGirl.build(
                :mdm_module_architecture,
                architecture: architecture,
                module_instance: module_instance
            )
          end
        end
      end
    end
  end
end