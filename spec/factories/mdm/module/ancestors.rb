FactoryGirl.define do
  factory :mdm_module_ancestor, :class => Mdm::Module::Ancestor do
    #
    # Associations
    #

    association :parent_path, :factory => :mdm_module_path

    #
    # Attributes
    #

    module_type { generate :mdm_module_ancestor_module_type }

    ignore do
      # depends on module_type
      payload_type {
        if payload?
          generate :mdm_module_ancestor_payload_type
        else
          nil
        end
      }
    end

    # depends on module_type
    reference_name {
      if payload?
        payload_type_directory = payload_type.pluralize
        relative_payload_name = generate :mdm_module_ancestor_relative_payload_name

        [
            payload_type_directory,
            relative_payload_name
        ].join('/')
      else
        generate :mdm_module_ancestor_non_payload_reference_name
      end
    }

    # depends on derived_payload_type which depends on reference_name
    handler_type {
      # can't use #handled? because it will check payload_type on model, not ignored field in factory, so use
      # .handled?
      if Mdm::Module::Ancestor.handled?(:module_type => module_type, :payload_type => derived_payload_type)
        generate :mdm_module_ancestor_handler_type
      else
        nil
      end
    }


    #
    # Callbacks
    #

    after(:build) do |ancestor|
      path = ancestor.derived_real_path

      if path
        pathname = Pathname.new(path)
        Metasploit::Model::Spec::PathnameCollision.check!(pathname)
        # make directory
        pathname.parent.mkpath

        # make file
        pathname.open('w') do |f|
          f.puts "# Module Type: #{ancestor.module_type}"
          f.puts "# Reference Name: #{ancestor.reference_name}"
        end
      end
    end

    #
    # Child Factories
    #

    factory :non_payload_mdm_module_ancestor do
      module_type { generate :mdm_module_ancestor_non_payload_module_type }

      ignore do
        payload_type nil
      end
    end

    factory :payload_mdm_module_ancestor do
      module_type 'payload'

      ignore do
        payload_type { generate :mdm_module_ancestor_payload_type }
      end

      reference_name {
        payload_type_directory = payload_type.pluralize
        relative_payload_name = generate :mdm_module_ancestor_relative_payload_name

        [
            payload_type_directory,
            relative_payload_name
        ].join('/')
      }

      factory :single_payload_mdm_module_ancestor do
        ignore do
          payload_type 'single'
        end
      end

      factory :stage_payload_mdm_module_ancestor do
        ignore do
          payload_type 'stage'
        end
      end

      factory :stager_payload_mdm_module_ancestor do
        ignore do
          payload_type 'stager'
        end
      end
    end
  end

  sequence :mdm_module_ancestor_handler_type do |n|
    "mdm_module_ancestor_handler_type#{n}"
  end

  sequence :mdm_module_ancestor_module_type, Metasploit::Model::Module::Type::ALL.cycle

  non_payload_ordered_types = Metasploit::Model::Module::Type::ALL - ['payload']
  sequence :mdm_module_ancestor_non_payload_module_type, non_payload_ordered_types.cycle

  sequence :mdm_module_ancestor_non_payload_reference_name do |n|
    [
        'mdm',
        'module',
        'ancestor',
        'non',
        'payload',
        'reference',
        "name#{n}"
    ].join('/')
  end

  sequence :mdm_module_ancestor_payload_type, Mdm::Module::Ancestor::PAYLOAD_TYPES.cycle

  payload_type_directories = Mdm::Module::Ancestor::PAYLOAD_TYPES.map(&:pluralize)

  sequence :mdm_module_ancestor_payload_type_directory, payload_type_directories.cycle

  sequence :mdm_module_ancestor_payload_reference_name do |n|
    payload_type_directory = payload_type_directories[n % payload_type_directories.length]

    [
        payload_type_directory,
        'mdm',
        'module',
        'ancestor',
        'payload',
        'reference',
        "name#{n}"
    ].join('/')
  end

  sequence :mdm_module_ancestor_relative_payload_name do |n|
    [
        'mdm',
        'module',
        'ancestor',
        'relative',
        'payload',
        "name#{n}"
    ].join('/')
  end
end