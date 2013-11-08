require 'spec_helper'

describe Mdm::Module::Architecture do
  context 'associations' do
    it { should belong_to(:architecture).class_name('Mdm::Architecture') }
    it { should belong_to(:module_instance).class_name('Mdm::Module::Instance') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:architecture_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:module_instance_id).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:module_instance_id, :architecture_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_module_architecture' do
      subject(:mdm_module_architecture) do
        FactoryGirl.build(:mdm_module_architecture)
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:architecture_id) }
    it { should_not allow_mass_assignment_of(:module_instance_id) }
  end

  context 'validations' do
    it { should validate_presence_of(:architecture) }

    # Can't use validate_uniqueness_of(:architecture_id).scoped_to(:module_instance_id) because it will attempt to
    # INSERT with NULL module_instance_id, which is invalid.
    context 'validate uniqueness of architecture_id scoped to module_instance_id' do
      let(:existing_architecture) do
        FactoryGirl.generate :mdm_architecture
      end

      let(:existing_module_class) do
        FactoryGirl.create(
            :mdm_module_class,
            module_type: module_type
        )
      end

      let(:existing_module_instance) do
        FactoryGirl.build(
            :mdm_module_instance,
            module_architectures_length: 0,
            module_class: existing_module_class,
        ).tap { |module_instance|
          module_instance.module_architectures << FactoryGirl.build(
              :mdm_module_architecture,
              architecture: existing_architecture,
              module_instance: module_instance
          )
        }
      end

      let(:module_type) do
        module_types.sample
      end

      let(:module_types) do
        module_architectures_module_types = Metasploit::Model::Module::Instance.module_types_that_allow(:module_architectures)
        targets_module_types = Metasploit::Model::Module::Instance.module_types_that_allow(:targets)

        # have to remove target module types so that target architectures don't interfere with module architectures
        module_architectures_module_types - targets_module_types
      end

      before(:each) do
        existing_module_instance.save!
      end

      context 'with same architecture_id' do
        subject(:new_module_architecture) do
          FactoryGirl.build(
              :mdm_module_architecture,
              :architecture => existing_architecture,
              :module_instance => existing_module_instance
          )
        end

        before(:each) do
          existing_module_instance.module_architectures << new_module_architecture
        end

        it { should_not be_valid }

        it 'should record error on architecture_id' do
          new_module_architecture.valid?

          new_module_architecture.errors[:architecture_id].should include('has already been taken')
        end
      end

      context 'without same architecture_id' do
        subject(:new_module_architecture) do
          FactoryGirl.build(
              :mdm_module_architecture,
              :architecture => new_architecture,
              :module_instance => existing_module_instance
          )
        end

        let(:new_architecture) do
          FactoryGirl.generate :mdm_architecture
        end

        before(:each) do
          existing_module_instance.module_architectures << new_module_architecture
        end

        it { should be_valid }
      end
    end

    it { should validate_presence_of(:module_instance) }
  end
end