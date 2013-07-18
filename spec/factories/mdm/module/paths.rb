FactoryGirl.define do
  factory :mdm_module_path,
          :aliases => [
              :unnamed_mdm_module_path
          ],
          :class => Mdm::Module::Path,
          :traits => [
              :unnamed_metasploit_model_module_path
          ] do
    factory :named_mdm_module_path,
            :traits => [
                :named_metasploit_model_module_path
            ]
  end
end