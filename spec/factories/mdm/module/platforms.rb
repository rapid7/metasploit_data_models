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

    module_instance { FactoryGirl.create(:mdm_module_instance, module_class: module_class) }
    platform { generate :mdm_platform }
  end
end