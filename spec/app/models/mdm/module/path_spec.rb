require 'spec_helper'

describe Mdm::Module::Path do
  it_should_behave_like 'Metasploit::Model::Module::Path',
                        namespace_name: 'Mdm'

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

  context '#each_changed_module_ancestor' do
    subject(:each_changed_module_ancestor) do
      path.each_changed_module_ancestor(options, &block)
    end

    #
    # lets
    #

    let(:new_module_ancestors) do
      # makes file on disk, but not Mdm::Module::Ancestor record in database
      FactoryGirl.build_list(
          :mdm_module_ancestor,
          2,
          parent_path: path
      )
    end

    let(:options) do
      {
          changed: true
      }
    end

    let(:path) do
      FactoryGirl.create(:mdm_module_path)
    end

    #
    # let!s
    #

    let!(:existing_module_ancestors) do
      FactoryGirl.create_list(
          :mdm_module_ancestor,
          2,
          parent_path: path
      )
    end


    before(:each) do
      # validate to derive real_path
      new_module_ancestors.each(&:valid?)
    end

    context 'with block' do
      let(:block) do
        lambda { |module_ancestor|
        }
      end

      let(:existing_module_ancestor_real_paths) do
        existing_module_ancestors.map(&:real_path)
      end

      let(:module_ancestors) do
        existing_module_ancestors + new_module_ancestors
      end

      let(:module_ancestor_real_paths) do
        existing_module_ancestor_real_paths + new_module_ancestor_real_paths
      end

      let(:new_module_ancestor_real_paths) do
        new_module_ancestors.map(&:derived_real_path)
      end

      it 'should use #module_ancestor_real_paths to gather Metasploit::Model::Module::Ancestor#real_path' do
        path.should_receive(:module_ancestor_real_paths).and_return([])

        each_changed_module_ancestor
      end

      it 'should call ActiveRecord::Base.connection_pool.with_connection around database accesses' do
        ActiveRecord::Base.connection_pool.should_receive(:with_connection) do |&block|
          new = double('ActiveRecord::Association#new')
          where_relation = double('ActiveRecord::Relation#where', find_each: nil)
          module_ancestors = double(
              'Mdm::Module::Path#module_ancestor',
              new: new,
              where: where_relation
          )
          with_connection = double('With Connection', module_ancestors: module_ancestors)

          with_connection.instance_eval(&block)
        end

        each_changed_module_ancestor
      end

      it 'should use one query to find all updatable Mdm::Module::Ancestors' do
        path.module_ancestors.should_receive(:where) { |hash|
          hash.should have_key(:real_path)
          actual_real_paths = hash[:real_path]
          actual_real_paths.should be_an Array

          expect(actual_real_paths).to match_array(module_ancestor_real_paths)
        }.and_call_original

        each_changed_module_ancestor
      end

      it 'should use Set to calculate new real_paths' do
        set = Set.new(module_ancestor_real_paths)
        Set.should_receive(:new) { |actual_real_paths|
          expect(actual_real_paths).to match_array(module_ancestor_real_paths)
        }.and_return(set)

        existing_module_ancestor_real_paths.each do |real_path|
          set.should_receive(:delete).with(real_path).and_call_original
        end

        each_changed_module_ancestor
      end

      it 'should only fetch :changed option once as a loop optimization' do
        options.should_receive(:fetch).with(:changed, false)
        options.should_not_receive(:[])

        each_changed_module_ancestor
      end

      context ':changed option' do
        context 'with true' do
          let(:options) do
            {
                changed: true
            }
          end

          it 'should yield existing and new Mdm::Module::Ancestors' do
            changed_module_ancestors = path.each_changed_module_ancestor(options)

            existing_module_ancestors.each do |existing_module_ancestor|
              changed_module_ancestors.should include(existing_module_ancestor)
            end

            actual_real_paths = changed_module_ancestors.map(&:real_path)

            new_module_ancestor_real_paths.each do |real_path|
              actual_real_paths.should include(real_path)
            end
          end
        end

        context 'with false' do
          subject(:changed_module_ancestors) do
            path.each_changed_module_ancestor(options).to_a
          end

          let(:options) do
            {
                changed: false
            }
          end

          context 'without change to file modification time' do
            it 'should yield only new Mdm::Module::Ancestors' do
              actual_real_paths = changed_module_ancestors.map(&:real_path)

              changed_module_ancestors.all? { |module_ancestor|
                module_ancestor.new_record?
              }.should be_true

              expect(actual_real_paths).to match_array(new_module_ancestor_real_paths)
            end
          end

          context 'with change to file modification time' do
            def change_real_path_modification_time(module_ancestor)
              changed_time_with_zone = module_ancestor.real_path_modified_at + 5.seconds
              changed_time = changed_time_with_zone.time()
              File.utime(changed_time, changed_time, module_ancestor.real_path)
            end

            context 'with change to file contents' do
              def change_contents(module_ancestor)
                File.open(module_ancestor.real_path, 'a') do |f|
                  f.puts "# Change to contents"
                end
              end

              before(:each) do
                existing_module_ancestors.each do |existing_module_ancestor|
                  change_contents(existing_module_ancestor)
                  # have to change modification time after changing contents as changing contents will write to the
                  # file, which will update atime and mtime.
                  change_real_path_modification_time(existing_module_ancestor)
                end
              end

              it 'should return all Mdm::module::Ancestors' do
                actual_real_paths = changed_module_ancestors.map(&:real_path)

                existing_module_ancestors.each do |existing_module_ancestor|
                  actual_real_paths.should include(existing_module_ancestor.real_path)
                end

                new_module_ancestors.each do |new_module_ancestor|
                  actual_real_paths.should include(new_module_ancestor.real_path)
                end
              end

              context 'existing Mdm::Module::Ancestors' do
                it 'should update #real_path_modified_at' do
                  existing_module_ancestors.each do |existing_module_ancestor|
                    changed_module_ancestor = changed_module_ancestors.find { |changed_module_ancestor|
                      changed_module_ancestor == existing_module_ancestor
                    }

                    changed_module_ancestor.real_path_modified_at.should_not == existing_module_ancestor.real_path_modified_at
                  end
                end

                it 'should update #real_path_sha1_hex_digest' do
                  existing_module_ancestors.each do |existing_module_ancestor|
                    changed_module_ancestor = changed_module_ancestors.find { |changed_module_ancestor|
                      changed_module_ancestor == existing_module_ancestor
                    }

                    changed_module_ancestor.real_path_sha1_hex_digest.should_not == existing_module_ancestor.real_path_sha1_hex_digest
                  end
                end
              end
            end

            context 'without change to file contents' do
              before(:each) do
                existing_module_ancestors.each do |existing_module_ancestor|
                  change_real_path_modification_time(existing_module_ancestor)
                end
              end

              it 'should not return pre-existing Mdm::Module::Ancestor because real_path_sha1_hex_digest has not changed' do
                existing_module_ancestors.each do |existing_module_ancestor|
                  changed_module_ancestors.should_not include(existing_module_ancestor)
                end
              end
            end
          end
        end
      end
    end

    context 'without block' do
      let(:block) do
        nil
      end

      it { should be_an Enumerator }
    end
  end

  context '#module_ancestor_real_paths' do
    subject(:module_ancestor_real_paths) do
      module_path.module_ancestor_real_paths
    end

    #
    # lets
    #

    let(:module_path) do
      FactoryGirl.create(:mdm_module_path)
    end

    #
    # let!s
    #

    let!(:existing_module_ancestors) do
      FactoryGirl.create_list(
          :mdm_module_ancestor,
          2,
          parent_path: module_path
      )
    end

    let!(:new_module_ancestors) do
      FactoryGirl.create_list(
          :mdm_module_ancestor,
          2,
          parent_path: module_path
      )
    end

    #
    # callbacks
    #

    before(:each) do
      2.times do |n|
        module_path.real_pathname.join("directory_#{n}").mkpath
      end

      2.times do |n|
        module_path.real_pathname.join("file_#{n}").open('wb') do |f|
          f.puts "File without extension #{n}"
        end
      end
    end

    it 'should use #module_ancestor_rule to find Metasploit::Model::Module::Ancestor#real_paths' do
      module_path.should_receive(:module_ancestor_rule).and_call_original

      module_ancestor_real_paths
    end

    it 'should not include directories' do
      module_ancestor_real_paths.any? { |real_path|
        File.directory?(real_path)
      }.should be_false
    end

    it 'should only include files' do
      module_ancestor_real_paths.all? { |real_path|
        File.file?(real_path)
      }.should be_true
    end

    it 'should only include file names with Metasploit::Model::Module::Ancestor::EXTENSION' do
      module_ancestor_real_paths.all? { |real_path|
        File.extname(real_path) == Metasploit::Model::Module::Ancestor::EXTENSION
      }.should be_true
    end

    it 'should include all Mdm::Module::Ancestor#real_paths' do
      expected_real_paths = []
      expected_real_paths.concat existing_module_ancestors.map(&:real_path)
      expected_real_paths.concat new_module_ancestors.map(&:derived_real_path)

      expect(module_ancestor_real_paths).to match_array(expected_real_paths)
    end
  end

  context '#module_ancestor_rule' do
    subject(:module_ancestor_rule) do
      module_path.module_ancestor_rule
    end

    let(:module_path) do
      FactoryGirl.create(:mdm_module_path)
    end

    it { should be_a File::Find }

    its(:ftype) { should == 'file' }

    context '#path' do
      subject(:path) do
        module_ancestor_rule.path
      end

      it 'should be Mdm::Module::Path#real_path' do
        path.should == module_path.real_path
      end
    end

    context '#pattern' do
      subject(:pattern) do
        module_ancestor_rule.pattern
      end

      it 'should be file with Metasploit::Model::Module::Ancetor::EXTENSION' do
        pattern.should == "*#{Metasploit::Model::Module::Ancestor::EXTENSION}"
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