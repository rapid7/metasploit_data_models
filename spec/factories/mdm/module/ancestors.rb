FactoryGirl.define do
  # Used to test {Metasploit::Model::Module::Ancestor} and to ensure that traits work when used in factories.
  factory :mdm_module_ancestor,
          :class => Mdm::Module::Ancestor,
          :traits => [
              :metasploit_model_module_ancestor
          ] do
    #
    # Associations
    #

    association :parent_path, :factory => :mdm_module_path

    #
    # Child Factories
    #

    factory :non_payload_mdm_module_ancestor,
            :traits => [
                :non_payload_metasploit_model_module_ancestor
            ]

    factory :payload_mdm_module_ancestor,
            :traits => [
                :payload_metasploit_model_module_ancestor
            ] do
      factory :single_payload_mdm_module_ancestor,
              :traits => [
                  :single_payload_metasploit_model_module_ancestor
              ]

      factory :stage_payload_mdm_module_ancestor,
              :traits => [
                  :stage_payload_metasploit_model_module_ancestor
              ]

      factory :stager_payload_mdm_module_ancestor,
              :traits => [
                  :stager_payload_metasploit_model_module_ancestor
              ]
    end
  end
end
