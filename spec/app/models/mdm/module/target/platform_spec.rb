require 'spec_helper'

describe Mdm::Module::Target::Platform do
  it_should_behave_like 'Metasploit::Model::Module::Target::Platform',
                        namespace_name: 'Mdm'

  context 'associations' do
    it { should belong_to(:module_target).class_name('Mdm::Module::Target') }
    it { should belong_to(:platform).class_name('Mdm::Platform') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:module_target_id).of_type(:integer).with_options(null: false) }
      it { should have_db_column(:platform_id).of_type(:integer).with_options(null: false) }
    end

    context 'indices' do
      it { should have_db_index([:module_target_id, :platform_id]).unique(true) }
    end
  end

  context 'validations' do
    context 'validates uniqueness of platform_id scoped to module_target_id' do
      #
      # lets
      #

      let(:new_module_target_platform) do
        FactoryGirl.build(
            :mdm_module_target_platform,
            platform: existing_module_target_platform.platform,
            module_target: existing_module_target_platform.module_target
        )
      end

      #
      # let!s
      #

      let!(:existing_module_target_platform) do
        FactoryGirl.create(:mdm_module_target_platform)
      end

      it 'should include error' do
        new_module_target_platform.valid?

        new_module_target_platform.errors[:platform_id].should include('has already been taken')
      end
    end
  end
end