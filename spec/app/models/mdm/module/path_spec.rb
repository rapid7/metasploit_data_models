require 'spec_helper'

describe Mdm::Module::Path do
  it_should_behave_like 'Metasploit::Model::Module::Path' do
    let(:path_class) do
      described_class
    end

    let(:path_factory) do
      :mdm_module_path
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
            FactoryGirl.generate :metasploit_model_module_path_real_path
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
        FactoryGirl.generate :metasploit_model_module_path_real_path
      end

      it 'should validate uniqueness of real path' do
        original = FactoryGirl.create(:mdm_module_path, :real_path => real_path)
        duplicate = FactoryGirl.build(:mdm_module_path, :real_path => real_path)

        duplicate.should_not be_valid
        duplicate.errors[:real_path].should include('has already been taken')
      end
    end
  end

  context '#module_ancestor_from_real_path' do
    subject(:module_ancestor_from_real_path) do
      path.module_ancestor_from_real_path(real_path, options)
    end

    let(:module_ancestor) do
      FactoryGirl.build(
          :mdm_module_ancestor,
          :parent_path => path
      )
    end

    let(:options) do
      {}
    end

    let(:path) do
      FactoryGirl.create(:mdm_module_path)
    end

    let(:real_path) do
      # need to use derived_real_path as real_path is not derived until validation.
      module_ancestor.derived_real_path
    end

    it 'should call ActiveRecord::Base.connection_pool.with_connection around database accesses' do
      ActiveRecord::Base.connection_pool.should_receive(:with_connection) do |&block|
        module_ancestor = double('Mdm::Module::Ancestor').as_null_object
        where_relation = double('ActiveRecord::Relation#where', first_or_initialize: module_ancestor)
        module_ancestors = double('Mdm::Module::Path#module_ancestors', where: where_relation)
        with_connection = double('With Connection', module_ancestors: module_ancestors)
        module_ancestor.should_receive(:save!)

        with_connection.instance_eval(&block)
      end

      module_ancestor_from_real_path
    end

    context 'with pre-existing Mdm::Module::Ancestor' do
      before(:each) do
        # Place the modification time in the past so it can be changed to the present when needed
        past_modification_time = File.mtime(real_path) - 5.seconds
        past_access_time = past_modification_time
        File.utime(past_access_time, past_modification_time, real_path)

        # save with altered real_path_modification_time
        module_ancestor.save!
      end

      context 'with change to file modification time' do
        before(:each) do
          changed_time = Time.now
          File.utime(changed_time, changed_time, module_ancestor.real_path)
        end

        context 'with change to file contents' do
          before(:each) do
            File.open(real_path, 'a') do |f|
              f.puts "# Change to file"
            end
          end

          it 'should return pre-existing Mdm::Module::Ancestor' do
            module_ancestor_from_real_path.should == module_ancestor
          end

          context 'Mdm::Module::Ancestor' do
            before(:each) do
              @real_path_modified_at = module_ancestor.real_path_modified_at
              @real_path_sha1_hex_digest = module_ancestor.real_path_sha1_hex_digest

              module_ancestor_from_real_path

              module_ancestor.reload
            end

            it 'should update #real_path_modified_at' do
              module_ancestor.real_path_modified_at.should_not == @real_path_modified_at
            end

            it 'should update #real_path_sha1_hex_digest' do
              module_ancestor.real_path_sha1_hex_digest.should_not == @real_path_modified_at
            end
          end
        end

        context 'without change to file contents' do
          it { should be_nil }

          context 'Mdm::Module::Ancestor' do
            before(:each) do
              @real_path_modified_at = module_ancestor.real_path_modified_at

              module_ancestor_from_real_path

              module_ancestor.reload
            end

            it 'should update #real_path_modified_at' do
              module_ancestor.real_path_modified_at.should_not == @real_path_modified_at
            end
          end
        end
      end

      context 'without change to file modification time' do
        context 'with changed: true' do
          let(:options) do
            {
                changed: true
            }
          end

          it 'should return pre-existing Mdm::Module::Ancestor' do
            module_ancestor_from_real_path.should == module_ancestor
          end
        end

        context 'with changed: false' do
          let(:options) do
            {
                changed: false
            }
          end

          it { should be_nil }
        end
      end
    end

    context 'without pre-existing Mdm::Module::Ancestor' do
      it 'should create Mdm::Module::Ancestor' do
        expect {
          module_ancestor_from_real_path
        }.to change(Mdm::Module::Ancestor, :count)
      end
    end
  end

  context '#name_collision' do
    subject(:name_collision) do
      path.name_collision
    end

    let!(:collision) do
      FactoryGirl.create(:named_mdm_module_path)
    end

    let!(:other_named) do
      FactoryGirl.create(:named_mdm_module_path)
    end

    let!(:unnamed) do
      FactoryGirl.create(:unnamed_mdm_module_path)
    end

    before(:each) do
      path.valid?
    end

    context 'with named' do
      context 'with same (gem, name)' do
        let(:path) do
          FactoryGirl.build(
              :named_mdm_module_path,
              :gem => collision.gem,
              :name => collision.name
          )
        end

        it 'should return collision' do
          name_collision.should == collision
        end
      end

      context 'without same (gem, name)' do
        let(:path) do
          FactoryGirl.build(:named_mdm_module_path)
        end

        it { should be_nil }
      end
    end

    context 'without named' do
      let(:path) do
        FactoryGirl.build(:unnamed_mdm_module_path)
      end

      it { should be_nil }
    end
  end

  context '#real_path_collision' do
    subject(:real_path_collision) do
      path.real_path_collision
    end

    let!(:collision) do
      FactoryGirl.create(:mdm_module_path)
    end

    context 'with same real_path' do
      let(:path) do
        FactoryGirl.build(:mdm_module_path, :real_path => collision.real_path)
      end

      it 'should return collision' do
        real_path_collision.should == collision
      end
    end

    context 'without same real_path' do
      let(:path) do
        FactoryGirl.build(:mdm_module_path)
      end

      it { should be_nil }
    end
  end
end