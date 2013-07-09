require 'spec_helper'

describe Mdm::Module::Path do
  context 'associations' do
    it { should have_many(:module_ancestors).class_name('Mdm::Module::Ancestor').dependent(:destroy).with_foreign_key(:parent_path_id) }
  end

  context 'callbacks' do
    context 'before validation' do
      context '#normalize_real_path' do
        let(:parent_pathname) do
          Metasploit::Model::Spec.temporary_pathname.join('mdm', 'module', 'path')
        end

        let(:path) do
          FactoryGirl.build(
              :mdm_module_path,
              :real_path => symlink_pathname.to_path
          )
        end

        let(:real_basename) do
          'real'
        end

        let(:real_pathname) do
          parent_pathname.join(real_basename)
        end

        let(:symlink_basename) do
          'symlink'
        end

        let(:symlink_pathname) do
          parent_pathname.join(symlink_basename)
        end

        before(:each) do
          real_pathname.mkpath

          Dir.chdir(parent_pathname.to_path) do
            File.symlink(real_basename, 'symlink')
          end
        end

        after(:each) do
          Metasploit::Model::Spec.temporary_pathname.rmtree
        end

        it 'should convert real_path to a real path using File#real_path' do
          expected_real_path = Metasploit::Model::File.realpath(path.real_path)

          path.real_path.should_not == expected_real_path

          path.valid?

          path.real_path.should == expected_real_path
        end
      end

      context 'nilify blanks' do
        let(:path) do
          FactoryGirl.build(
              :mdm_module_path,
              :gem => '',
              :name => '',
              # don't care about real_path validation or path validity, so real_path can be nil.
              :real_path => nil
          )
        end

        it 'should have empty gem' do
          path.gem.should_not be_nil
          path.gem.should be_empty
        end

        it 'should have empty name' do
          path.name.should_not be_nil
          path.name.should be_empty
        end

        context 'after validation' do
          before(:each) do
            path.valid?
          end

          its(:gem) { should be_nil }
          its(:name) { should be_nil }
        end
      end
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:gem).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:name).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:real_path).of_type(:text).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:gem, :name]).unique(true) }
      it { should have_db_index(:real_path).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_module_path' do
      subject(:mdm_module_path) do
        FactoryGirl.build(:mdm_module_path)
      end

      it { should be_valid }
    end

    context 'named_mdm_module_path' do
      subject(:named_mdm_module_path) do
        FactoryGirl.build(:named_mdm_module_path)
      end

      it { should be_valid }

      its(:gem) { should_not be_nil }
      its(:name) { should_not be_nil }
    end
  end

  context 'validations' do
    context 'gem and name' do
      let(:gem_error) do
        "can't be blank if name is present"
      end

      let(:name_error) do
        "can't be blank if gem is present"
      end

      subject(:path) do
        FactoryGirl.build(
            :named_mdm_module_path,
            :gem => gem,
            :name => name,
            # don't care about real_path validation or path validity, so real_path can be nil.
            :real_path => nil
        )
      end

      before(:each) do
        path.valid?
      end

      context 'with gem' do
        let(:gem) do
          'metasploit_data_models'
        end

        context 'with name' do
          let(:name) do
            'modules'
          end

          it 'should not record error on gem' do
            path.errors[:gem].should_not include(gem_error)
          end

          it 'should not record error on name' do
            path.errors[:name].should_not include(name_error)
          end
        end

        context 'without name' do
          let(:name) do
            nil
          end

          it 'should not record error on gem' do
            path.errors[:gem].should_not include(gem_error)
          end

          it 'should record error on name' do
            path.errors[:name].should include(name_error)
          end
        end
      end

      context 'without gem' do
        let(:gem) do
          nil
        end

        context 'with name' do
          let(:name) do
            'modules'
          end

          it 'should record error on gem' do
            path.errors[:gem].should include(gem_error)
          end

          it 'should not record error on name' do
            path.errors[:name].should_not include(name_error)
          end
        end

        context 'without name' do
          let(:name) do
            nil
          end

          it 'should not record error on gem' do
            path.errors[:gem].should_not include(gem_error)
          end

          it 'should not record error on name' do
            path.errors[:name].should_not include(name_error)
          end
        end
      end
    end

    context 'validate unique of name scoped to gem' do
      context 'with different real_paths' do
        let(:duplicate) do
          FactoryGirl.build(
              :named_mdm_module_path,
              :gem => original.gem,
              :name => original.name
          )
        end

        # let! so it exists in database for duplicate to validate against
        let!(:original) do
          FactoryGirl.create(
              :named_mdm_module_path
          )
        end

        it 'should validate uniqueness of name scoped to gem' do
          duplicate.should_not be_valid
          duplicate.errors[:name].should include('has already been taken')
        end
      end
    end

    context 'real_path' do
      let(:real_path) do
        FactoryGirl.generate :mdm_module_path_real_path
      end

      it 'should validate uniqueness of real path' do
        original = FactoryGirl.create(:mdm_module_path, :real_path => real_path)
        duplicate = FactoryGirl.build(:mdm_module_path, :real_path => real_path)

        duplicate.should_not be_valid
        duplicate.errors[:real_path].should include('has already been taken')
      end

      context 'presence' do
        subject(:path) do
          FactoryGirl.build(:mdm_module_path, :real_path => real_path)
        end

        context 'with nil' do
          let(:real_path) do
            nil
          end

          it { should_not be_valid }

          it 'should record error' do
            path.valid?

            path.errors[:real_path].should include("can't be blank")
          end
        end

        context "with ''" do
          let(:real_path) do
            ''
          end

          it { should_not be_valid }

          it 'should record error' do
            path.valid?

            path.errors[:real_path].should include("can't be blank")
          end
        end
      end

      it { should validate_directory_at(:real_path) }
    end
  end
end