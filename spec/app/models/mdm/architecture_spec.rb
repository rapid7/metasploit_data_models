require 'spec_helper'

describe Mdm::Architecture do
  subject(:architecture) do
    described_class.new
  end

  context 'associations' do
    it { should have_many(:hosts).class_name('Mdm::Host').dependent(:nullify) }
    it { should have_many(:module_architectures).class_name('Mdm::Module::Architecture').dependent(:destroy) }
    it { should have_many(:module_instances).class_name('Mdm::Module::Instance').through(:module_architectures) }
  end

  context 'constants' do
    context 'ABBREVIATIONS' do
      subject(:abbreviations) do
        described_class::ABBREVIATIONS
      end

      it 'should be an Array<String>' do
        abbreviations.should be_an Array

        abbreviations.each do |architecture|
          architecture.should be_a String
        end
      end

      it 'should include both endians of ARM' do
        abbreviations.should include('armbe')
        abbreviations.should include('armle')
      end

      it 'should include 32-bit and 64-bit versions of Cell Broadband Engine Architecture' do
        abbreviations.should include('cbea')
        abbreviations.should include('cbea64')
      end

      it 'should include cmd for command shell' do
        abbreviations.should include('cmd')
      end

      it 'should include java for Java Virtual Machine' do
        abbreviations.should include('java')
      end

      it 'should include endian-ware MIPS' do
        abbreviations.should include('mipsbe')
        abbreviations.should include('mipsle')
      end

      it 'should include php for PHP code' do
        abbreviations.should include('php')
      end

      it 'should include 32-bit and 64-bit PowerPC' do
        abbreviations.should include('ppc')
        abbreviations.should include('ppc64')
      end

      it 'should include ruby for Ruby code' do
        abbreviations.should include('ruby')
      end

      it 'should include sparc for Sparc' do
        abbreviations.should include('sparc')
      end

      it 'should include tty for Terminals' do
        abbreviations.should include('tty')
      end

      it 'should include 32-bit and 64-bit x86' do
        abbreviations.should include('x86')
        abbreviations.should include('x86_64')
      end
    end
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
    context 'abbreviation' do
      # have to test inclusion validation manually because
      # ensure_inclusion_of(:abbreviation).in_array(described_class::ABBREVIATIONS).allow_nil does not work with
      # additional uniqueness validation.
      context 'ensure inclusion of abbreviation in ABBREVIATIONS' do
        let(:error) do
          'is not included in the list'
        end

        abbreviations = [
            'armbe',
            'armle',
            'cbea',
            'cbea64',
            'cmd',
            'java',
            'mipsbe',
            'mipsle',
            'php',
            'ppc',
            'ppc64',
            'ruby',
            'sparc',
            'tty',
            'x86',
            'x86_64'
        ]

        abbreviations.each do |abbreviation|
          context "with #{abbreviation.inspect}" do
            before(:each) do
              architecture.abbreviation = abbreviation

              architecture.valid?
            end

            it 'should not record error on abbreviation' do
              architecture.errors[:abbreviation].should_not include(error)
            end
          end
        end
      end

      it { should validate_uniqueness_of(:abbreviation) }
    end

    it { should ensure_inclusion_of(:bits).in_array(described_class::BITS).allow_nil }
    it { should ensure_inclusion_of(:endianness).in_array(described_class::ENDIANNESSES).allow_nil }
    it { should ensure_inclusion_of(:family).in_array(described_class::FAMILIES).allow_nil }

    context 'summary' do
      it { should validate_presence_of(:summary) }
      it { should validate_uniqueness_of(:summary) }
    end
  end
end