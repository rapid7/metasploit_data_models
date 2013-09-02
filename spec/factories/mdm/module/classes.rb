FactoryGirl.define do
  factory :mdm_module_class,
          :class => Mdm::Module::Class,
          :traits => [
              :metasploit_model_module_class
          ] do
    # depends on module_type and payload_type
    ancestors {
      ancestors  = []

      # ignored attribute from factory; NOT the instance attribute
      case module_type
        when 'payload'
          # ignored attribute from factory; NOT the instance attribute
          case payload_type
            when 'single'
              ancestors << FactoryGirl.create(:single_payload_mdm_module_ancestor)
            when 'staged'
              ancestors << FactoryGirl.create(:stage_payload_mdm_module_ancestor)
              ancestors << FactoryGirl.create(:stager_payload_mdm_module_ancestor)
            else
              raise ArgumentError,
                    "Don't know how to create Mdm::Module::Class#ancestors " \
                    "for Mdm::Module::Class#payload_type (#{payload_type})"
          end
        else
          ancestors << FactoryGirl.create(:mdm_module_ancestor, :module_type => module_type)
      end

      ancestors
    }

    rank { generate :mdm_module_rank }

    factory :stanced_mdm_module_class do
      ignore do
        # derives from associations in instance, so don't set on instance
        module_type { generate :metasploit_model_module_instance_stanced_module_type }
      end
    end
  end
end