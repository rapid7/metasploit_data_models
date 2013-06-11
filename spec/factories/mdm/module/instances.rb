FactoryGirl.define do
  factory :mdm_module_instance, :class => Mdm::Module::Instance do
    #
    # Associations
    #

    association :module_class, :factory => :mdm_module_class

    #
    # Attributes
    #

    description { generate :mdm_module_instance_description }
    disclosed_on { generate :mdm_module_instance_disclosed_on }
    license { generate :mdm_module_instance_license }
    name { generate :mdm_module_instance_name }
    privileged { generate :mdm_module_instance_privileged }

    stance {
      if supports_stance?
        generate :mdm_module_instance_stance
      else
        nil
      end
    }
  end

  sequence :mdm_module_instance_description do |n|
    "Module Description #{n}"
  end

  sequence :mdm_module_instance_disclosed_on do |n|
    Date.today - n
  end

  sequence :mdm_module_instance_license do |n|
    "Module License #{n}"
  end

  sequence :mdm_module_instance_name do |n|
    "Module Name #{n}"
  end

  sequence :mdm_module_instance_privileged, Mdm::Module::Instance::PRIVILEGES.cycle

  sequence :mdm_module_instance_stance, Mdm::Module::Instance::STANCES.cycle
end