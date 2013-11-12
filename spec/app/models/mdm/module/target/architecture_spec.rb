require 'spec_helper'

describe Mdm::Module::Target::Architecture do
  it_should_behave_like 'Metasploit::Model::Module::Target::Architecture',
                        namespace_name: 'Mdm'

  context 'associations' do
    it { should belong_to(:architecture).class_name('Mdm::Architecture') }
    it { should belong_to(:module_target).class_name('Mdm::Module::Target') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:architecture_id).of_type(:integer).with_options(null: false) }
      it { should have_db_column(:module_target_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { should have_db_index([:module_target_id, :architecture_id]).unique(true) }
    end
  end

  context 'validations' do
    context 'validates uniqueness of architecture_id scoped to module_target_id' do
      #
      # lets
      #

      let(:architecture) do
        existing_module_target_architecture.architecture
      end

      let(:error) do
        I18n.translate!('metasploit.model.errors.messages.taken')
      end

      let(:module_target) do
        existing_module_target_architecture.module_target
      end

      let(:new_module_target_architecture) do
        # have to construct with target_architectures.build as assigning with factory will trigger a save when
        # target architecture is << to target.target_architectures and target is already saved.
        module_target.target_architectures.build(
            new_module_target_architecture_attributes
        ).tap { |target_architecture|
          target_architecture.architecture = architecture
        }
      end

      let(:new_module_target_architecture_attributes) do
        FactoryGirl.attributes_for(
            :mdm_module_target_architecture,
            # don't want factory building these attributes, but also don't want them in hash as they can't be
            # mass-assigned
            architecture: nil,
            module_target: nil
        ).except(
            :architecture,
            :module_target
        )
      end

      #
      # let!s
      #

      let!(:existing_module_target_architecture) do
        FactoryGirl.create(:mdm_module_target_architecture)
      end

      context 'with batched' do
        include_context 'MetasploitDataModels::Batch.batch'

        it 'should include error' do
          new_module_target_architecture.valid?

          new_module_target_architecture.errors[:architecture_id].should_not include(error)
        end

        it 'should raise ActiveRecord::RecordNotUnique when saved' do
          expect {
            new_module_target_architecture.save
          }.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end

      context 'without batched' do
        it 'should include error' do
          new_module_target_architecture.valid?

          new_module_target_architecture.errors[:architecture_id].should include(error)
        end
      end
    end
  end
end