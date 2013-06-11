FactoryGirl.define do
  factory :mdm_module_class, :class => Mdm::Module::Class do
    #
    # Attributes
    #

    # Don't set full_name: before_validation will derive it from {Mdm::Module::Class#module_type} and
    # {Mdm::Module::Class::reference_name}.

    ignore do
      # derives from associations in instance, so don't set on instance
      module_type { generate :mdm_module_class_module_type }

      # depends on module_type
      # ignored because model attribute will derived from reference_name, this factory attribute is used to generate
      # the correct reference_name.
      payload_type {
        # module_type is factory attribute, not model attribute
        if module_type == 'payload'
          generate :mdm_module_class_payload_type
        else
          nil
        end
      }
    end

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
  end

  #
  # Although these sequences are defined the same as their :mdm_module_ancestor_* equivalent it is desirable (1) that
  # they be independent in cycling and (2) not require developers to remember to use :mdm_module_ancestor sequences to
  # set :mdm_module_class attributes.
  #

  ordered_types = Mdm::Module::Ancestor::MODULE_TYPES.sort
  sequence :mdm_module_class_module_type, ordered_types.cycle

  non_payload_ordered_types = ordered_types - ['payload']
  sequence :mdm_module_class_non_payload_module_type, non_payload_ordered_types.cycle

  sequence :mdm_module_class_payload_type, Mdm::Module::Class::PAYLOAD_TYPES.cycle
end