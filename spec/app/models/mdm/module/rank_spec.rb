require 'spec_helper'

describe Mdm::Module::Rank do
  subject(:rank) do
    FactoryGirl.generate :mdm_module_rank
  end

  it_should_behave_like 'Metasploit::Model::Module::Rank',
                        namespace_name: 'Mdm' do
    # have to delete the seeds because Metasploit::Model::Module::Rank validations specs can't handle uniqueness
    # constraint supplied by database model.
    before(:each) do
      described_class.destroy_all
    end
  end

  context 'associations' do
    it { should have_many(:module_classes).class_name('Mdm::Module::Class').dependent(:destroy) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:name).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:number).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index(:name).unique(true) }
      it { should have_db_index(:number).unique(true) }
    end
  end

  context 'validations' do
    it { should validate_uniqueness_of(:name) }
    it { should validate_uniqueness_of(:number) }
  end
end