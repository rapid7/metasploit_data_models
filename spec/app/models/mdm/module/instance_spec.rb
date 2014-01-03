require 'spec_helper'

describe Mdm::Module::Instance do
  subject(:module_instance) do
    FactoryGirl.build(:mdm_module_instance)
  end

  it_should_behave_like 'Metasploit::Model::Module::Instance',
                        namespace_name: 'Mdm'

  context 'associations' do
    it { should have_many(:actions).class_name('Mdm::Module::Action').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:architectures).class_name('Mdm::Architecture').through(:module_architectures) }
    it { should have_many(:authors).class_name('Mdm::Author').through(:module_authors) }
    it { should have_many(:authorities).class_name('Mdm::Authority').through(:references) }
    it { should belong_to(:default_action).class_name('Mdm::Module::Action') }
    it { should belong_to(:default_target).class_name('Mdm::Module::Target') }
    it { should have_many(:email_addresses).class_name('Mdm::EmailAddress').through(:module_authors) }
    it { should have_many(:module_architectures).class_name('Mdm::Module::Architecture').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:module_authors).class_name('Mdm::Module::Author').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should belong_to(:module_class).class_name('Mdm::Module::Class') }
    it { should have_many(:module_platforms).class_name('Mdm::Module::Platform').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:module_references).class_name('Mdm::Module::Reference').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:platforms).class_name('Mdm::Platform').through(:module_platforms) }
    it { should have_one(:rank).class_name('Mdm::Module::Rank').through(:module_class) }
    it { should have_many(:references).class_name('Mdm::Reference').through(:module_references) }
    it { should have_many(:targets).class_name('Mdm::Module::Target').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:vuln_references).class_name('Mdm::VulnReference').through(:references) }
    it { should have_many(:vulnerable_hosts).class_name('Mdm::Host').through(:vulns) }
    it { should have_many(:vulnerable_services).class_name('Mdm::Service').through(:vulns) }
    it { should have_many(:vulns).class_name('Mdm::Vuln').through(:vuln_references) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:default_action_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:default_target_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:description).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:disclosed_on).of_type(:date).with_options(:null => true) }
      it { should have_db_column(:license).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:module_class_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:name).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:privileged).of_type(:boolean).with_options(:null => false) }
      it { should have_db_column(:stance).of_type(:string).with_options(:null => true) }
    end

    context 'indices' do
      it { should have_db_index(:default_action_id).unique(true) }
      it { should have_db_index(:default_target_id).unique(true) }
      it { should have_db_index(:module_class_id).unique(true) }
    end
  end

  context 'scopes' do
    context 'compatible_privilege_with' do
      subject(:compatible_privilege_with) do
        described_class.compatible_privilege_with(module_instance)
      end

      #
      # let!s
      #

      let!(:module_instance) do
        FactoryGirl.create(
            :mdm_module_instance,
            privileged: privilege
        )
      end

      let!(:privileged) do
        FactoryGirl.create(
            :mdm_module_instance,
            privileged: true
        )
      end

      let!(:unprivileged) do
        FactoryGirl.create(
            :mdm_module_instance,
            privileged: false
        )
      end

      context 'with privileged' do
        let(:privilege) do
          true
        end

        it 'includes privileged Mdm::Module::Instances' do
          expect(compatible_privilege_with).to include(privileged)
        end

        it 'does not include unprivileged Mdm::Module::Instances' do
          expect(compatible_privilege_with).not_to include(unprivileged)
        end
      end

      context 'without privileged' do
        let(:privilege) do
          false
        end

        it 'includes privileged Mdm::Module::Instances' do
          expect(compatible_privilege_with).to include(privileged)
        end

        it 'includes unprivileged Mdm::Module::Instances' do
          expect(compatible_privilege_with).to include(unprivileged)
        end
      end
    end

    context 'intersecting_architectures_with' do
      subject(:intersecting_architectures_with) do
        described_class.intersecting_architectures_with(module_target)
      end

      #
      # lets
      #

      let(:architecture) do
        FactoryGirl.generate :mdm_architecture
      end

      let(:module_target) do
        FactoryGirl.build(
            :mdm_module_target,
            target_architectures_length: 0
        ).tap { |module_target|
          module_target.target_architectures.build(
              {
                architecture: architecture
              },
              {
                  without_protection: true
              }
          )

          module_target.module_instance.module_architectures.build(
              {
                  architecture: architecture
              },
              {
                  without_protection: true
              }
          )
        }
      end

      let(:other_module_class) do
        FactoryGirl.create(
            :mdm_module_class,
            module_type: other_module_type
        )
      end

      let(:other_module_type) do
        'payload'
      end

      #
      # Callbacks
      #

      before(:each) do
        module_target.save!
      end

      context 'with intersection' do
        #
        # lets
        #

        let(:other_module_instance) do
          FactoryGirl.build(
              :mdm_module_instance,
              module_class: other_module_class,
              module_architectures_length: 0
          ).tap { |module_instance|
            module_instance.module_architectures.build(
                {
                    architecture: architecture
                },
                {
                    without_protection: true
                }
            )
          }
        end

        #
        # Callbacks
        #

        before(:each) do
          other_module_instance.save!
        end

        it 'includes Mdm::Module::Instance with same Mdm::Architecture' do
          expect(intersecting_architectures_with).to include(other_module_instance)
        end
      end

      context 'without intersection' do
        #
        # lets
        #

        let(:other_architecture) do
          FactoryGirl.generate :mdm_architecture
        end

        let(:other_module_instance) do
          FactoryGirl.build(
              :mdm_module_instance,
              module_class: other_module_class,
              module_architectures_length: 0
          ).tap { |module_instance|
            module_instance.module_architectures.build(
                {
                    architecture: other_architecture
                },
                {
                    without_protection: true
                }
            )
          }
        end

        #
        # Callbacks
        #

        before(:each) do
          other_module_instance.save!
        end

        it 'does include Mdm::Module::Instance without same Mdm::Architecture' do
          expect(intersecting_architectures_with).not_to include(other_module_instance)
        end
      end
    end

    context 'intersecting_platforms_with' do
      subject(:intersecting_platforms_with) do
        described_class.intersecting_platforms_with(module_target)
      end

      #
      # lets
      #

      let(:platform) do
        Mdm::Platform.where(fully_qualified_name: platform_fully_qualified_name).first
      end

      let(:platform_fully_qualified_name) do
        'Windows XP'
      end

      let(:module_target) do
        FactoryGirl.build(
            :mdm_module_target,
            target_platforms_length: 0
        ).tap { |module_target|
          module_target.target_platforms.build(
              {
                  platform: platform
              },
              {
                  without_protection: true
              }
          )

          module_target.module_instance.module_platforms.build(
              {
                  platform: platform
              },
              {
                  without_protection: true
              }
          )
        }
      end

      let(:other_module_class) do
        FactoryGirl.create(
            :mdm_module_class,
            module_type: other_module_type
        )
      end

      let(:other_module_instance) do
        FactoryGirl.build(
            :mdm_module_instance,
            module_class: other_module_class,
            module_platforms_length: 0
        ).tap { |module_instance|
          module_instance.module_platforms.build(
              {
                  platform: other_platform
              },
              {
                  without_protection: true
              }
          )
        }
      end

      let(:other_module_type) do
        'payload'
      end

      let(:other_platform) do
        Mdm::Platform.where(fully_qualified_name: other_platform_fully_qualified_name).first
      end

      #
      # Callbacks
      #

      before(:each) do
        module_target.save!
        other_module_instance.save!
      end

      context 'with same platform' do
        let(:other_platform) do
          platform
        end

        it 'includes the Mdm::Module::Instance' do
          expect(intersecting_platforms_with).to include(other_module_instance)
        end
      end

      context 'with ancestor platform' do
        let(:other_platform_fully_qualified_name) do
          'Windows'
        end

        it 'includes the Mdm::Module::Instance' do
          expect(intersecting_platforms_with).to include(other_module_instance)
        end
      end

      context 'with descendant platform' do
         let(:other_platform_fully_qualified_name) do
          'Windows XP SP1'
        end

        it 'includes the Mdm::Module::Instance' do
          expect(intersecting_platforms_with).to include(other_module_instance)
        end
      end

      context 'with cousin platform' do
        let(:other_platform_fully_qualified_name) do
          'Windows XP SP1'
        end

        let(:platform_fully_qualified_name) do
          'Windows 2000 SP1'
        end

        it 'does not include Mdm::Module::Instance' do
          expect(intersecting_platforms_with).not_to include(other_module_instance)
        end
      end

      context 'with unrelated platform' do
        let(:other_platform_fully_qualified_name) do
          'UNIX'
        end

        it 'does not include Mdm::Module::Instance' do
          expect(intersecting_platforms_with).not_to include(other_module_instance)
        end
      end
    end

    context 'payloads' do
      subject(:payloads) do
        described_class.payloads
      end

      #
      # let!s
      #

      let!(:module_class_by_module_type) do
        Metasploit::Model::Module::Type::ALL.each_with_object({}) { |module_type, module_class_by_module_type|
          module_class = FactoryGirl.create(
              :mdm_module_class,
              module_type: module_type
          )

          module_class_by_module_type[module_type] = module_class
        }
      end

      let!(:module_instance_by_module_type) do
        module_class_by_module_type.each_with_object({}) { |(module_type, module_class), module_instance_by_module_type|
          module_instance = FactoryGirl.create(
              :mdm_module_instance,
              module_class: module_class
          )

          module_instance_by_module_type[module_type] = module_instance
        }
      end

      it 'includes payload' do
        expect(payloads).to include(module_instance_by_module_type['payload'])
      end

      Metasploit::Model::Module::Type::NON_PAYLOAD.each do |module_type|
        it "does not include #{module_type}" do
          expect(payloads).not_to include(module_instance_by_module_type[module_type])
        end
      end
    end

    context 'payloads_compatible_with' do
      subject(:payloads_compatible_with) do
        described_class.payloads_compatible_with(module_target)
      end

      #
      # lets
      #

      let(:architecture) do
        FactoryGirl.generate :mdm_architecture
      end

      let(:module_target) do
        FactoryGirl.build(
            :mdm_module_target,
            target_architectures_length: 0,
            target_platforms_length: 0
        ).tap { |module_target|
          module_target.target_architectures.build(
              {
                  architecture: architecture
              },
              {
                  without_protection: true
              }
          )

          module_target.module_instance.module_architectures.build(
              {
                  architecture: architecture
              },
              {
                  without_protection: true
              }
          )

          module_target.target_platforms.build(
              {
                  platform: platform
              },
              {
                  without_protection: true
              }
          )

          module_target.module_instance.module_platforms.build(
              {
                  platform: platform
              },
              {
                  without_protection: true
              }
          )
        }
      end

      let(:platform) do
        Mdm::Platform.where(fully_qualified_name: platform_fully_qualified_name).first
      end

      let(:platform_fully_qualified_name) do
        'Windows XP'
      end

      #
      # Callbacks
      #

      before(:each) do
        module_target.save!
      end

      it 'calls payloads' do
        expect(described_class).to receive(:payloads).and_call_original

        payloads_compatible_with
      end

      it 'calls compatible_privilege_with on the module_target.module_instance' do
        expect(described_class).to receive(:compatible_privilege_with).with(module_target.module_instance).and_call_original

        payloads_compatible_with
      end

      it 'calls intersecting_architectures_with on the module_target' do
        expect(described_class).to receive(:intersecting_architectures_with).with(module_target).and_call_original

        payloads_compatible_with
      end

      it 'calls intersecting_paltforms_with on the module_target' do
        expect(described_class).to receive(:intersecting_platforms_with).with(module_target).and_call_original

        payloads_compatible_with
      end
    end
  end

  context '#targets' do
    subject(:targets) do
      module_instance.targets
    end

    context 'with unsaved module_instance' do
      let(:module_instance) do
        FactoryGirl.build(
            :mdm_module_instance,
            module_class: module_class
        )
      end

      let(:module_class) do
        FactoryGirl.create(
            :mdm_module_class,
            module_type: module_type
        )
      end

      let(:module_type) do
        module_types.sample
      end

      let(:module_types) do
        Metasploit::Model::Module::Instance.module_types_that_allow(:targets)
      end

      context 'built without :module_instance' do
        subject(:module_target) do
          targets.build(
              name: name
          )
        end

        let(:name) do
          FactoryGirl.generate :metasploit_model_module_target_name
        end

        context '#module_instance' do
          subject(:module_target_module_instance) do
            module_target.module_instance
          end

          it 'should be the original module instance' do
            module_target_module_instance.should == module_instance
          end
        end
      end
    end
  end
end