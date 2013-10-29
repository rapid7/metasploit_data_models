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

      let(:new_module_target_architecture) do
        FactoryGirl.build(
            :mdm_module_target_architecture,
            architecture: existing_module_target_architecture.architecture,
            module_target: existing_module_target_architecture.module_target
        )
      end

      #
      # let!s
      #

      let!(:existing_module_target_architecture) do
        FactoryGirl.create(:mdm_module_target_architecture)
      end

      it 'should include error' do
        new_module_target_architecture.valid?

        new_module_target_architecture.errors[:architecture_id].should include('has already been taken')
      end
    end
  end
end