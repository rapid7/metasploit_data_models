require 'spec_helper'

describe Mdm::Module::Author do

  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { should belong_to(:detail).class_name('Mdm::Module::Detail') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:detail_id).of_type(:integer) }
      it { should have_db_column(:name).of_type(:text) }
      it { should have_db_column(:email).of_type(:text) }
    end

    context 'indices' do
      it { should have_db_index(:detail_id) }
    end
  end

  context 'factories' do
    context 'full_mdm_module_author' do
      subject(:full_mdm_module_author) do
        FactoryGirl.build :full_mdm_module_author
      end

      it { should be_valid }
      its(:email) { should_not be_nil }
    end

    context 'mdm_module_author' do
      subject(:mdm_module_author) do
        FactoryGirl.build :mdm_module_author
      end

      it { should be_valid }
    end
  end

  context 'validations' do
    it { should validate_presence_of(:detail) }
    it { should_not validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
  end
end