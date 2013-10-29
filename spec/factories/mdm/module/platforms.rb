FactoryGirl.define do
  factory :mdm_module_platform,
          class: Mdm::Module::Platform,
          traits: [
              :metasploit_model_module_platform
          ] do
    ignore do
      # have to use module_type from metasploit_model_module_platform trait to ensure module_instance will support
      # module platforms.
      module_class { FactoryGirl.create(:mdm_module_class, module_type: module_type) }
    end

    module_instance {
      FactoryGirl.build(
          :mdm_module_instance,
          module_class: module_class,
          # disable module_instance factory from building module_platforms since this factory is already building one
          module_platforms_length: 0
      )
    }
    platform { generate :mdm_platform }

    after(:build) do |module_platform|
      module_instance = module_platform.module_instance

      if module_instance
        unless module_instance.module_platforms.include? module_platform
          module_instance.module_platforms << module_platform
        end
      end
    end
  end
end