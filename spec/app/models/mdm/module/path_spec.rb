require 'spec_helper'

describe Mdm::Module::Path do
  it_should_behave_like 'Metasploit::Model::Module::Path' do
    let(:path_class) do
      described_class
    end
  end

  context 'associations' do
    it { should have_many(:module_ancestors).class_name('Mdm::Module::Ancestor').dependent(:destroy).with_foreign_key(:parent_path_id) }
  end

  context 'callbacks' do
    context 'after update' do
      context '#update_module_ancestor_real_paths' do
        context 'with change to #real_path' do
          let!(:path) do
            FactoryGirl.create(:mdm_module_path)
          end

          let(:new_real_path) do
            FactoryGirl.generate :mdm_module_path_real_path
          end

          context 'with #module_ancestors' do
            let!(:ancestors) do
              FactoryGirl.create_list(:mdm_module_ancestor, 2, :parent_path => path)
            end

            before(:each) do
              # Have to remove new_real_path as sequence will have already created it
              FileUtils.rmdir(new_real_path)
              # Move old real_path to new real_path to simulate install location for path changing and to ensure
              # that ancestors exist on path.
              FileUtils.mv(path.real_path, new_real_path)

              path.real_path = new_real_path
            end

            it 'should save without errors' do
              expect {
                path.save!
              }.to_not raise_error
            end

            it "should update ancestor's real_paths" do
              expect {
                path.save!
              }.to change {
                # true = reload association
                path.module_ancestors(true).map(&:real_path)
              }
            end
          end
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