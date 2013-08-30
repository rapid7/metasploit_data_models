require 'spec_helper'

describe Mdm::Author do
  it_should_behave_like 'Metasploit::Model::Author' do
    let(:author_class) do
      described_class
    end
  end

  context 'associations' do
    it { should have_many(:email_addresses).class_name('Mdm::EmailAddress').through(:module_authors) }
    it { should have_many(:module_authors).class_name('Mdm::Module::Author').dependent(:destroy) }
    it { should have_many(:module_instances).class_name('Mdm::Module::Instance').through(:module_authors) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:name).of_type(:string).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index(:name).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_author' do
      subject(:mdm_author) do
        FactoryGirl.build(:mdm_author)
      end

      it { should be_valid }
    end
  end

  context 'validations' do
    it { should validate_uniqueness_of :name }
  end
end