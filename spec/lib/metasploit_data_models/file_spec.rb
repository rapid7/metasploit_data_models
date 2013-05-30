require 'spec_helper'

describe MetasploitDataModels::File do
  context 'realpath' do
    let(:dummy_pathname) do
      MetasploitDataModels.root.join('spec', 'dummy')
    end

    let(:real_basename) do
      'real'
    end

    let(:real_pathname) do
      dummy_pathname.join(real_basename)
    end

    let(:symlink_basename) do
      'symlink'
    end

    let(:symlink_pathname) do
      dummy_pathname.join(symlink_basename)
    end

    before(:each) do
      real_pathname.mkpath

      Dir.chdir(dummy_pathname.to_path) do
        File.symlink(real_basename, 'symlink')
      end
    end

    after(:each) do
      real_pathname.rmtree
      symlink_pathname.rmtree
    end

    def realpath
      described_class.realpath(symlink_pathname.to_path)
    end

    if RUBY_PLATFORM =~ /java/
      it 'should be necessary because File.realpath does not resolve symlinks' do
        File.realpath(symlink_pathname.to_path).should_not == real_pathname.to_path
      end
    end

    it 'should resolve symlink to real (canonical) path' do
      realpath.should == real_pathname.to_path
    end
  end
end