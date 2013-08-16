require 'spec_helper'

describe Mdm::Architecture do
  subject(:architecture) do
    described_class.new
  end

  it_should_behave_like 'Metasploit::Model::Architecture' do
    let(:architecture_class) do
      described_class
    end
  end

  context 'associations' do
    it { should have_many(:hosts).class_name('Mdm::Host').dependent(:nullify) }
    it { should have_many(:module_architectures).class_name('Mdm::Module::Architecture').dependent(:destroy) }
    it { should have_many(:module_instances).class_name('Mdm::Module::Instance').through(:module_architectures) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:abbreviation).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:bits).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:endianness).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:family).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:summary).of_type(:string).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index(:abbreviation).unique(true) }
      it { should have_db_index(:summary).unique(true) }
    end
  end

  context 'seeds' do
    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'armbe',
                          :bits => 32,
                          :endianness => 'big',
                          :family => 'arm',
                          :summary => 'Little-endian ARM'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'armle',
                          :bits => 32,
                          :endianness => 'little',
                          :family => 'arm',
                          :summary => 'Big-endian ARM'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'cbea',
                          :bits => 32,
                          :endianness => 'big',
                          :family => 'cbea',
                          :summary => '32-bit Cell Broadband Engine Architecture'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'cbea64',
                          :bits => 64,
                          :endianness => 'big',
                          :family => 'cbea',
                          :summary => '64-bit Cell Broadband Engine Architecture'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'cmd',
                          :bits => nil,
                          :endianness => nil,
                          :family => nil,
                          :summary => 'Command Injection'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'java',
                          :bits => nil,
                          :endianness => 'big',
                          :family => nil,
                          :summary => 'Java'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'mipsbe',
                          :bits => 32,
                          :endianness => 'big',
                          :family => 'mips',
                          :summary => 'Big-endian MIPS'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'mipsle',
                          :bits => 32,
                          :endianness => 'little',
                          :family => 'mips',
                          :summary => 'Little-endian MIPS'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'php',
                          :bits => nil,
                          :endianness => nil,
                          :family => nil,
                          :summary => 'PHP'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'ppc',
                          :bits => 32,
                          :endianness => 'big',
                          :family => 'ppc',
                          :summary => '32-bit Peformance Optimization With Enhanced RISC - Performance Computing'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'ppc64',
                          :bits => 64,
                          :endianness => 'big',
                          :family => 'ppc',
                          :summary => '64-bit Performance Optimization With Enhanced RISC - Performance Computing'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'ruby',
                          :bits => nil,
                          :endianness => nil,
                          :family => nil,
                          :summary => 'Ruby'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'sparc',
                          :bits => nil,
                          :endianness => nil,
                          :family => 'sparc',
                          :summary => 'Scalable Processor ARChitecture'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'tty',
                          :bits => nil,
                          :endianness => nil,
                          :family => nil,
                          :summary => '*nix terminal'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'x86',
                          :bits => 32,
                          :endianness => 'little',
                          :family => 'x86',
                          :summary => '32-bit x86'

    it_should_behave_like 'Mdm::Architecture seed',
                          :abbreviation => 'x86_64',
                          :bits => 64,
                          :endianness => 'little',
                          :family => 'x86',
                          :summary => '64-bit x86'
  end

  context 'validations' do
    it { should validate_uniqueness_of(:abbreviation) }
    it { should validate_uniqueness_of(:summary) }
  end
end