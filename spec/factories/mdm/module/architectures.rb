FactoryGirl.define do
  factory :mdm_module_architecture,
          class: Mdm::Module::Architecture,
          traits: [
              :metasploit_model_module_architecture
          ] do
    ignore do
      # have to use module_type from metasploit_model_module_architecture trait to ensure module_instance will support
      # module architectures.
      module_class { FactoryGirl.create(:mdm_module_class, module_type: module_type) }
    end

    architecture { generate :mdm_architecture }
    module_instance {
      FactoryGirl.build(
          :mdm_module_instance,
          # disable module_instance factory from building module_architectures since this factory is already building
          # one
          module_architectures_length: 0,
          module_class: module_class
      )
    }

    after(:build) do |module_architecture|
      module_instance = module_architecture.module_instance

      if module_instance
        unless module_instance.module_architectures.include? module_architecture
          module_instance.module_architectures << module_architecture
        end
      end
    end
  end
end