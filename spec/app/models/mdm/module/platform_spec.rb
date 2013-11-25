require 'spec_helper'

describe Mdm::Module::Platform do
  it_should_behave_like 'Metasploit::Model::Module::Platform',
                        namespace_name: 'Mdm'

  context 'associations' do
    it { should belong_to(:module_instance).class_name('Mdm::Module::Instance') }
    it { should belong_to(:platform).class_name('Mdm::Platform') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:module_instance_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:platform_id).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:module_instance_id, :platform_id]).unique(true) }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:module_instance_id) }
    it { should_not allow_mass_assignment_of(:platform_id) }
  end

  context 'validations' do
    # Can't use validate_uniqueness_of(:platform_id).scoped_to(:module_instance_id) because it will attempt to set
    # module_instance_id to nil.
    context 'validate uniqueness of platform_id scoped to module_instance_id' do
      #
      # lets
      #

      let(:existing_module_platform) do
        module_instance.module_platforms.first
      end

      let(:existing_platform) do
        existing_module_platform.platform
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
        [
            # does NOT include 'exploits' as don't want to deal with target platforms
            'payload',
            'post'
        ]
      end

      #
      # let!s
      #

      let!(:module_instance) do
        FactoryGirl.create(
            :mdm_module_instance,
            module_class: module_class,
            # only a single module platform as that is all that is required for collision
            module_platforms_length: 1,
        )
      end

      context 'with same platform_id' do
        subject(:new_module_platform) do
          module_instance.module_platforms.build.tap { |module_platform|
            module_platform.platform = existing_platform
          }
        end

        context 'with batched' do
          include_context 'MetasploitDataModels::Batch.batch'

          it 'should not add error on #platform_id' do
            new_module_platform.valid?

            new_module_platform.errors[:platform_id].should_not include('has already been taken')
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_module_platform.save
            }.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end

        context 'without batched' do
          it 'should record error on platform_id' do
            new_module_platform.valid?

            new_module_platform.errors[:platform_id].should include('has already been taken')
          end
        end
      end

      context 'without same platform_id' do
        subject(:new_module_platform) do
          FactoryGirl.build(
              :mdm_module_platform,
              :module_instance => module_instance,
              :platform => new_platform
          )
        end

        let(:new_platform) do
          FactoryGirl.generate :mdm_platform
        end

        it { should be_valid }
      end
    end
  end
end