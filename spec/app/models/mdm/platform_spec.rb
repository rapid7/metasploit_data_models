require 'spec_helper'

describe Mdm::Platform do
  it_should_behave_like 'Metasploit::Model::Platform',
                        namespace_name: 'Mdm' do
    include_context 'ActiveRecord attribute_type'
  end

  context 'associations' do
    it { should have_many(:module_platforms).class_name('Mdm::Module::Platform').dependent(:destroy) }
    it { should have_many(:module_instances).class_name('Mdm::Module::Instance').through(:module_platforms) }
    it { should have_many(:target_platforms).class_name('Mdm::Module::Target::Platform').dependent(:destroy) }
  end

  context 'database' do
    context 'columns' do
      context 'nested set' do
        it { should have_db_column(:parent_id).of_type(:integer).with_options(null: true) }
        it { should have_db_column(:right).of_type(:integer).with_options(null: false) }
        it { should have_db_column(:left).of_type(:integer).with_options(null: false) }
      end

      context 'platform' do
        it { should have_db_column(:fully_qualified_name).of_type(:text).with_options(null: false) }
        it { should have_db_column(:relative_name).of_type(:text).with_options(null: false) }
      end
    end

    context 'indices' do
      it { should have_db_index(:fully_qualified_name).unique(true) }
      it { should have_db_index([:parent_id, :relative_name]).unique(true) }
    end
  end
end