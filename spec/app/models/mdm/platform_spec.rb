require 'spec_helper'

describe Mdm::Platform do
  it_should_behave_like 'Metasploit::Model::Platform'

  context 'associations' do
    it { should have_many(:module_platforms).class_name('Mdm::Module::Platform').dependent(:destroy) }
    it { should have_many(:module_instances).class_name('Mdm::Module::Instance').through(:module_platforms) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:name).of_type(:text).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index(:name).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_platform' do
      subject(:mdm_platform) do
        FactoryGirl.build(:mdm_platform)
      end

      it { should be_valid }
    end
  end

  context 'validations' do
    it { should validate_uniqueness_of(:name) }
  end
end