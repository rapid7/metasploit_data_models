require 'spec_helper'

describe Mdm::Architecture do
  subject(:architecture) do
    described_class.new
  end

  it_should_behave_like 'Metasploit::Model::Architecture' do
    let(:seed) do
      described_class.where(abbreviation: abbreviation).first
    end
  end

  context 'associations' do
    it { should have_many(:hosts).class_name('Mdm::Host').dependent(:nullify) }
    it { should have_many(:module_architectures).class_name('Mdm::Module::Architecture').dependent(:destroy) }
    it { should have_many(:module_instances).class_name('Mdm::Module::Instance').through(:module_architectures) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:abbreviation).of_type(:string).with_options(null: false) }
      it { should have_db_column(:bits).of_type(:integer).with_options(null: true) }
      it { should have_db_column(:endianness).of_type(:string).with_options(null: true) }
      it { should have_db_column(:family).of_type(:string).with_options(null: true) }
      it { should have_db_column(:summary).of_type(:string).with_options(null: false) }
    end

    context 'indices' do
      it { should have_db_index(:abbreviation).unique(true) }
      it { should have_db_index(:summary).unique(true) }
    end
  end

  context 'validations' do
    it { should validate_uniqueness_of(:abbreviation) }
    it { should validate_uniqueness_of(:summary) }
  end
end