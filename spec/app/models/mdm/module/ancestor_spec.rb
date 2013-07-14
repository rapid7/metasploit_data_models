require 'spec_helper'

describe Mdm::Module::Ancestor do
  subject(:ancestor) do
    described_class.new
  end

  let(:module_types) do
    [
        'auxiliary',
        'encoder',
        'exploit',
        'nop',
        'payload',
        'post'
    ]
  end

  context 'CONSTANTS' do
    context 'EXTENSION' do
      subject(:extension) do
        described_class::EXTENSION
      end

      it 'should be ruby source extension' do
        extension.should == '.rb'
      end

      it "should start with '.'" do
        extension.should start_with('.')
      end
    end

    context 'HANDLED_TYPES' do
      subject(:handled_types) do
        described_class::HANDLED_TYPES
      end

      it { should include('single') }
      it { should_not include('stage') }
      it { should include('stager') }

      it 'should be a subset of PAYLOAD_TYPES' do
        handled_type_set = Set.new(handled_types)
        payload_type_set = Set.new(described_class::PAYLOAD_TYPES)

        handled_type_set.should be_a_subset(payload_type_set)
      end
    end

    context 'PAYLOAD_TYPES' do
      subject(:payload_types) do
        described_class::PAYLOAD_TYPES
      end

      it { should include('single') }
      it { should include('stage') }
      it { should include('stager') }
    end

    # pattern is tested in validation tests below
    it 'should define REFERENCE_NAME_REGEXP' do
      described_class::REFERENCE_NAME_REGEXP.should be_a Regexp
    end

    # pattern is tested in validation tests below
    it 'should define SHA_HEX_DIGEST_REGEXP' do
      described_class::SHA1_HEX_DIGEST_REGEXP.should be_a Regexp
    end
  end

  context 'associations' do
    it { should have_many(:descendants).class_name('Mdm::Module::Class').through(:relationships) }
    it { should belong_to(:parent_path).class_name('Mdm::Module::Path') }
    it { should have_many(:relationships).class_name('Mdm::Module::Relationship').dependent(:destroy) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:full_name).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:handler_type).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:module_type).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:real_path).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:real_path_modified_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:real_path_sha1_hex_digest).of_type(:string).with_options(:limit => 40, :null => false) }
      it { should have_db_column(:reference_name).of_type(:text).with_options(:null => false) }
    end

    context 'indices' do
      context 'foreign key' do
        it { should have_db_index(:parent_path_id) }
      end

      context 'unique' do
        subject(:ancestor) do
          described_class.new
        end

        it 'should have unique index on full_name to represent that Msf::ModuleManager only allows one module with a given full_name' do
          ancestor.should have_db_index(:full_name).unique(true)
        end

        it 'should have unique index on (module_type, reference_name) to present that Msf::ModuleSet and Msf::PayloadSet only allow one module with a given reference_name' do
          ancestor.should have_db_index([:module_type, :reference_name]).unique(true)
        end

        it 'should have unique index on real_path because only one file can have a given path' do
          ancestor.should have_db_index(:real_path).unique(true)
        end

        it 'should have unique index on real_path_sha1_hex_digest so renames can be detected' do
          ancestor.should have_db_index(:real_path_sha1_hex_digest).unique(true)
        end
      end
    end
  end

  context 'derivation' do
    subject(:ancestor) do
      FactoryGirl.build(:mdm_module_ancestor)
    end

    it_should_behave_like 'derives', :full_name, :validates => true
    it_should_behave_like 'derives', :real_path, :validates => true

    context 'with payload' do
      subject(:ancestor) do
        FactoryGirl.build(
            :mdm_module_ancestor,
            # {Mdm::Module::Ancestor#derived_payload_type} will be `nil` unless {Mdm::Module::Ancestor#module_type} is
            # `'payload'`
            :module_type => 'payload',
            # Ensure {Mdm::Module::Ancestor#derived_payload} will be a valid {Mdm::Module::Ancestor#payload_type}.
            :reference_name => reference_name
        )
      end

      let(:reference_name) do
        FactoryGirl.generate :mdm_module_ancestor_payload_reference_name
      end

      it_should_behave_like 'derives', :payload_type, :validates => true
    end

    # {Mdm::Module::Ancestor#derived_real_path_modified_at} and
    # {Mdm::Module::Ancestor#derived_real_path_sha1_hex_digest} both depend on real_path being populated  or they
    # will return nil, so need set real_path = derived_real_path before testing as would happen with the normal
    # order of before validation callbacks.
    context 'with real_path' do
      before(:each) do
        ancestor.real_path = ancestor.derived_real_path
      end

      it_should_behave_like 'derives', :real_path_modified_at, :validates => false
      it_should_behave_like 'derives', :real_path_sha1_hex_digest, :validates => false
    end
  end

  context 'factories' do
    context 'mdm_module_ancestor' do
      subject(:mdm_module_ancestor) do
        FactoryGirl.build(:mdm_module_ancestor)
      end

      it { should be_valid }
    end

    context 'payload_mdm_module_ancestor' do
      subject(:payload_mdm_module_ancestor) do
        FactoryGirl.build(:payload_mdm_module_ancestor)
      end

      it { should be_valid }

      its(:module_type) { should == 'payload' }
      its(:derived_payload_type) { should_not be_nil }
    end

    context 'single_payload_mdm_module_ancestor' do
      subject(:single_payload_mdm_module_ancestor) do
        FactoryGirl.build(:single_payload_mdm_module_ancestor)
      end

      it { should be_valid }

      its(:module_type) { should == 'payload' }
      its(:derived_payload_type) { should == 'single' }
    end

    context 'stage_payload_mdm_module_ancestor' do
      subject(:stage_payload_mdm_module_ancestor) do
        FactoryGirl.build(:stage_payload_mdm_module_ancestor)
      end

      it { should be_valid }

      its(:module_type) { should == 'payload' }
      its(:derived_payload_type) { should == 'stage' }
    end

    context 'stager_payload_mdm_module_ancestor' do
      subject(:stager_payload_mdm_module_ancestor) do
        FactoryGirl.build(:stager_payload_mdm_module_ancestor)
      end

      it { should be_valid }

      its(:module_type) { should == 'payload' }
      its(:derived_payload_type) { should == 'stager' }
    end
  end

  context 'mass assignment security' do
    it 'should not allow mass assignment of full_name since it must match derived_full_name' do
      ancestor.should_not allow_mass_assignment_of(:full_name)
    end

    it { should allow_mass_assignment_of(:handler_type) }
    it { should allow_mass_assignment_of(:module_type) }

    it 'should not allow mass assignment of payload_type since it must match derived_payload_type' do
      ancestor.should_not allow_mass_assignment_of(:payload_type)
    end

    it 'should not allow mass assignment of real_path since it must match derived_real_path' do
      ancestor.should_not allow_mass_assignment_of(:real_path)
    end

    it 'should not allow mass assignment of real_path_modified_at since it is derived' do
      ancestor.should_not allow_mass_assignment_of(:real_path_modified_at)
    end

    it 'should not allow mass assignment of real_path_sha1_hex_digest since it is derived' do
      ancestor.should_not allow_mass_assignment_of(:real_path_sha1_hex_digest)
    end

    it { should_not allow_mass_assignment_of(:parent_path_id) }
  end

  context 'validations' do
    context 'full_name' do
      # can't use validate_uniqueness_of(:full_name) because of null value in module_type
      context 'validates uniqueness' do
        let!(:original_ancestor) do
          FactoryGirl.create(:mdm_module_ancestor)
        end

        context 'with same full_name' do
          let(:same_full_name_ancestor) do
            FactoryGirl.build(
                :mdm_module_ancestor,
                # set module_type and reference_name as full_name is derived from them
                :module_type => original_ancestor.module_type,
                :reference_name => original_ancestor.reference_name
            )
          end

          it 'should record error on full_name' do
            same_full_name_ancestor.should_not be_valid
            same_full_name_ancestor.errors[:full_name].should include('has already been taken')
          end
        end
      end
    end

    it { should ensure_inclusion_of(:module_type).in_array(module_types) }

    context 'handler_type' do
      subject(:ancestor) do
        FactoryGirl.build(
            :mdm_module_ancestor,
            :handler_type => handler_type,
            :module_type => module_type,
            :payload_type => payload_type
        )
      end

      context 'with payload' do
        let(:module_type) do
          'payload'
        end

        context 'with payload_type' do
          context 'single' do
            let(:payload_type) do
              'single'
            end

            context 'with handler_type' do
              let(:handler_type) do
                FactoryGirl.generate :mdm_module_ancestor_handler_type
              end

              it {
                subject.valid?
                subject
              }
            end

            context 'without handler_type' do
              let(:handler_type) do
                nil
              end

              it { should_not be_valid }

              it 'should record error on handler_type' do
                ancestor.valid?

                ancestor.errors[:handler_type].should include("can't be blank")
              end
            end
          end

          context 'stage' do
            let(:payload_type) do
              'stage'
            end

            context 'with handler_type' do
              let(:handler_type) do
                FactoryGirl.generate :mdm_module_ancestor_handler_type
              end

              it { should_not be_valid }

              it 'should record error on handler_type' do
                ancestor.valid?

                ancestor.errors[:handler_type].should include('must be nil')
              end
            end

            context 'without handler_type' do
              let(:handler_type) do
                nil
              end

              it { should be_valid }
            end
          end

          context 'stager' do
            let(:payload_type) do
              'stager'
            end

            context 'with handler_type' do
              let(:handler_type) do
                FactoryGirl.generate :mdm_module_ancestor_handler_type
              end

              it { should be_valid }
            end

            context 'without handler_type' do
              let(:handler_type) do
                nil
              end

              it { should_not be_valid }

              it 'should record error on handler_type' do
                ancestor.valid?

                ancestor.errors[:handler_type].should include("can't be blank")
              end
            end
          end
        end
      end

      context 'without payload' do
        let(:module_type) do
          FactoryGirl.generate :mdm_module_ancestor_non_payload_module_type
        end

        context 'with payload_type' do
          # force payload_type to NOT be derived to check invalid setups
          before(:each) do
            ancestor.payload_type = payload_type
          end

          context 'single' do
            let(:payload_type) do
              'single'
            end

            context 'with handler_type' do
              let(:handler_type) do
                FactoryGirl.generate :mdm_module_ancestor_handler_type
              end

              it { should be_invalid }

              it 'should record error on handler_type' do
                ancestor.valid?

                ancestor.errors[:handler_type].should include('must be nil')
              end
            end

            context 'without handler_type' do
              let(:handler_type) do
                nil
              end

              it 'should not record error on handler_type' do
                ancestor.valid?

                ancestor.errors[:handler_type].should be_empty
              end
            end
          end

          context 'stage' do
            let(:payload_type) do
              'stage'
            end

            context 'with handler_type' do
              let(:handler_type) do
                FactoryGirl.generate :mdm_module_ancestor_handler_type
              end

              it { should_not be_valid }

              it 'should record error on handler_type' do
                ancestor.valid?

                ancestor.errors[:handler_type].should include('must be nil')
              end
            end

            context 'without handler_type' do
              let(:handler_type) do
                nil
              end

              it 'should not record error on handler_type' do
                ancestor.valid?

                ancestor.errors[:handler_type].should be_empty
              end
            end
          end

          context 'stager' do
            let(:payload_type) do
              'stager'
            end

            context 'with handler_type' do
              let(:handler_type) do
                FactoryGirl.generate :mdm_module_ancestor_handler_type
              end

              it { should_not be_valid }

              it 'should record error on handler_type' do
                ancestor.valid?

                ancestor.errors[:handler_type].should include('must be nil')
              end
            end

            context 'without handler_type' do
              let(:handler_type) do
                nil
              end

              it 'should not record error on handler_type' do
                ancestor.valid?

                ancestor.errors[:handler_type].should be_empty
              end
            end
          end
        end

        context 'without payload_type' do
          let(:payload_type) do
            nil
          end

          context 'with handler_type' do
            let(:handler_type) do
              FactoryGirl.generate(:mdm_module_ancestor_handler_type)
            end

            it { should_not be_valid }

            it 'should record error on handler_type' do
              ancestor.valid?

              ancestor.errors[:handler_type].should include('must be nil')
            end
          end

          context 'without handler_type' do
            let(:handler_type) do
              nil
            end

            it { should be_valid }
          end
        end
      end
    end

    it { should validate_presence_of(:parent_path) }

    context 'payload_type' do
      subject(:ancestor) do
        FactoryGirl.build(
            :mdm_module_ancestor,
            :module_type => module_type,
            :reference_name => reference_name
        )
      end

      before(:each) do
        # payload is ignored in mdm_module_ancestor factory so need set it directly
        ancestor.payload_type = payload_type
      end

      context 'with payload?' do
        let(:module_type) do
          'payload'
        end

        context 'with payload_type' do
          described_class::PAYLOAD_TYPES.each do |allowed_payload_type|
            context "with #{allowed_payload_type}" do
              let(:payload_type) do
                nil
              end

              let(:payload_type_directory) do
                allowed_payload_type.pluralize
              end

              let(:reference_name) do
                "#{payload_type_directory}/name"
              end

              it { should be_valid }
            end
          end
        end

        context 'without payload_type' do
          let(:payload_type) do
            nil
          end

          let(:reference_name) do
            FactoryGirl.generate :mdm_module_ancestor_non_payload_reference_name
          end

          it { should_not be_valid }

          it 'should record error on payload_type' do
            ancestor.valid?

            ancestor.errors[:payload_type].should include('is not included in the list')
          end
        end
      end

      context 'without payload?' do
        let(:module_type) do
          FactoryGirl.generate :mdm_module_ancestor_non_payload_module_type
        end

        context 'with payload_type' do
          # force payload to not be nil so that derive_payload_type is not called.
          let(:payload_type) do
            FactoryGirl.generate :mdm_module_ancestor_payload_type
          end

          let(:reference_name) do
            "#{payload_type.pluralize}/name"
          end

          it { should_not be_valid }

          it 'should record error on payload_type' do
            ancestor.valid?

            ancestor.errors[:payload_type].should include('must be nil')
          end
        end

        context 'without payload_type' do
          let(:payload_type) do
            nil
          end

          let(:reference_name) do
            FactoryGirl.generate :mdm_module_ancestor_non_payload_reference_name
          end

          it { should be_valid }
        end
      end
    end

    context 'real_path' do
      # can't use validate_uniqueness_of(:real_path) because of null full_name
      context 'validate presence' do
        let!(:original_ancestor) do
          FactoryGirl.create(:mdm_module_ancestor)
        end

        context 'with same real_path' do
          let(:same_real_path_ancestor) do
            FactoryGirl.build(
                :mdm_module_ancestor,
                # real_path is derived from parent_path, module_type, and reference_name, so set copy those attributes
                # to get the same real_path.
                :module_type => original_ancestor.module_type,
                :parent_path => original_ancestor.parent_path,
            ).tap do |ancestor|
              # At least one attribute needs to be set outside the call to build because the factory will attempt to
              # created the derived_real_path and throw a Metasploit::Model::Spec::PathnameCollision.
              ancestor.reference_name = original_ancestor.reference_name
            end
          end

          it 'should record error on real_path' do
            same_real_path_ancestor.should_not be_valid
            same_real_path_ancestor.errors[:real_path].should include('has already been taken')
          end
        end
      end
    end

    it { should validate_presence_of(:real_path_modified_at) }

    context 'real_path_sha1_hex_digest' do
      context 'validates format with SHA1_HEX_DIGEST_REGEXP' do
        let(:hexdigest) do
          Digest::SHA1.hexdigest('')
        end

        it 'should allow a Digest::SHA1.hexdigest' do
          ancestor.should allow_value(hexdigest).for(:real_path_sha1_hex_digest)
        end

        it 'should not allow a truncated Digest::SHA1.hexdigest' do
          ancestor.should_not allow_value(hexdigest[0, 39]).for(:real_path_sha1_hex_digest)
        end

        it 'should not allow upper case hex to maintain normalization' do
          ancestor.should_not allow_value(hexdigest.upcase).for(:real_path_sha1_hex_digest)
        end

        it { should_not allow_value(nil).for(:real_path_sha1_hex_digest) }
      end

      context 'validates uniqueness' do
        let!(:original_ancestor) do
          FactoryGirl.create(:mdm_module_ancestor)
        end

        context 'with same real_path_sha1_hex_digest' do
          let(:same_real_path_sha1_hex_digest_ancestor) do
            FactoryGirl.build(
                :mdm_module_ancestor,
                # real_path_sha1_hex_digest is derived, but not validated (as it would take too long)
                # so it can just be set directly
                :real_path_sha1_hex_digest => original_ancestor.real_path_sha1_hex_digest
            )
          end

          it 'should record error on real_path_sha1_hex_digest' do
            same_real_path_sha1_hex_digest_ancestor.should_not be_valid
            same_real_path_sha1_hex_digest_ancestor.errors[:real_path_sha1_hex_digest].should include('has already been taken')
          end
        end
      end
    end

    context 'reference_name' do
      context 'validates format with REFERENCE_NAME_REGEXP' do
        context 'without slashes' do
          context 'first character' do
            it 'should allow lowercase letter' do
              ancestor.should allow_value('a').for(:reference_name)
            end

            it 'should not allow uppercase letter' do
              ancestor.should_not allow_value('A').for(:reference_name)
            end

            it 'should not allow digit' do
              ancestor.should_not allow_value('9').for(:reference_name)
            end

            it 'should not allow underscore' do
              ancestor.should_not allow_value('_').for(:reference_name)
            end
          end

          context 'later letters' do
            let(:lowercase_letters) do
              ('a'..'z').to_a
            end

            let(:first_letter) do
              lowercase_letters.sample
            end

            it 'should allow lowercase letter' do
              ancestor.should allow_value("#{first_letter}a").for(:reference_name)
            end

            it 'should not allow uppercase letter' do
              ancestor.should_not allow_value("#{first_letter}A").for(:reference_name)
            end

            it 'should allow digit' do
              ancestor.should allow_value("#{first_letter}1").for(:reference_name)
            end

            it 'should allow underscore' do
              ancestor.should allow_value("#{first_letter}_").for(:reference_name)
            end
          end
        end

        context 'with slashes' do
          let(:section) do
            "a_1"
          end

          context 'leading' do
            it "should not allow '/'" do
              ancestor.should_not allow_value("/#{section}").for(:reference_name)
            end

            it "should not allow '\\'" do
              ancestor.should_not allow_value("\\#{section}").for(:reference_name)
            end
          end

          context 'infix' do
            it "should allow '/'" do
              ancestor.should allow_value("#{section}/#{section}").for(:reference_name)
            end

            it "should not allow '\\'" do
              ancestor.should_not allow_value("#{section}\\#{section}").for(:reference_name)
            end
          end

          context 'trailing' do
            it "should not allow '/'" do
              ancestor.should_not allow_value("#{section}/").for(:reference_name)
            end

            it "should not allow '\\'" do
              ancestor.should_not allow_value("#{section}\\").for(:reference_name)
            end
          end
        end
      end

      context 'validates uniqueness scoped to module_type' do
        let(:new_ancestor) do
          FactoryGirl.build(
              :mdm_module_ancestor,
              :module_type => new_module_type,
              :reference_name => new_reference_name
          )
        end

        let(:original_module_type) do
          # don't use payload so sequence can be used to generate reference_name
          FactoryGirl.generate :mdm_module_ancestor_non_payload_module_type
        end

        let(:original_reference_name) do
          FactoryGirl.generate :mdm_module_ancestor_non_payload_reference_name
        end

        let!(:original_ancestor) do
          FactoryGirl.create(
              :mdm_module_ancestor,
              :module_type => original_module_type,
              :reference_name => original_reference_name
          )
        end

        context 'with same module_type' do
          let(:new_module_type) do
            original_module_type
          end

          context 'with same reference_name' do
            let(:new_reference_name) do
              original_reference_name
            end

            it 'should record error on reference_name' do
              new_ancestor.should_not be_valid
              new_ancestor.errors[:reference_name].should include(I18n.translate!('activerecord.errors.messages.taken'))
            end
          end
        end

        context 'without same module_type' do
          let(:new_module_type) do
            # don't use payload so sequence can be used to generate reference_name
            FactoryGirl.generate :mdm_module_ancestor_non_payload_module_type
          end

          context 'with same reference_name' do
            let(:new_reference_name) do
              original_reference_name
            end

            it 'should not record error on reference_name' do
              new_ancestor.valid?

              new_ancestor.errors[:reference_name].should be_empty
            end
          end
        end
      end
    end
  end

  context '#derived_full_name' do
    subject(:derived_full_name) do
      ancestor.derived_full_name
    end

    let(:ancestor) do
      FactoryGirl.build(
          :mdm_module_ancestor,
          :module_type => module_type,
          # don't create parent_path since it's unneeded for tests
          :parent_path => nil
      )
    end

    context 'with module_type' do
      let(:module_type) do
        FactoryGirl.generate :mdm_module_ancestor_module_type
      end

      it "should equal <module_type>/<reference_name>" do
        derived_full_name.should == "#{ancestor.module_type}/#{ancestor.reference_name}"
      end
    end

    context 'without module_type' do
      let(:module_type) do
        nil
      end

      it { should be_nil }
    end
  end

  context '#derived_payload_type' do
    subject(:derived_payload_type) do
      ancestor.derived_payload_type
    end

    let(:ancestor) do
      FactoryGirl.build(
          :mdm_module_ancestor,
          :module_type => module_type
      )
    end

    context 'with payload' do
      let(:module_type) do
        'payload'
      end

      it 'should singularize payload_type_directory' do
        derived_payload_type.should == ancestor.payload_type_directory.singularize
      end
    end

    context 'without payload' do
      let(:module_type) do
        FactoryGirl.generate :mdm_module_ancestor_non_payload_module_type
      end

      it { should be_nil }
    end
  end

  context '#derived_real_path' do
    subject(:derived_real_path) do
      ancestor.derived_real_path
    end

    let(:ancestor) do
      FactoryGirl.build(
          :mdm_module_ancestor,
          :module_type => module_type,
          :parent_path => parent_path,
          :reference_name => reference_name
      )
    end

    let(:module_type) do
      nil
    end

    let(:parent_path) do
      nil
    end

    let(:reference_name) do
      nil
    end

    context 'with parent_path' do
      let(:parent_path) do
        FactoryGirl.build(
            :mdm_module_path,
            :real_path => parent_path_real_path
        )
      end

      context 'with parent_path.real_path' do
        let(:parent_path_real_path) do
          FactoryGirl.generate :mdm_module_path_real_path
        end

        context 'with module_type' do
          let(:module_type) do
            FactoryGirl.generate :mdm_module_ancestor_module_type
          end

          context 'with reference_name' do
            let(:reference_name) do
              FactoryGirl.generate :mdm_module_ancestor_non_payload_reference_name
            end

            it 'should be full path including parent_path.real_path, type_directory, and reference_path' do
              derived_real_path.should == File.join(
                  parent_path_real_path,
                  ancestor.module_type_directory,
                  ancestor.reference_path
              )
            end
          end

          context 'without reference_name' do
            let(:reference_name) do
              nil
            end

            it { should be_nil }
          end
        end

        context 'without module_type' do
          let(:module_type) do
            nil
          end

          it { should be_nil }
        end
      end

      context 'without parent_path.real_path' do
        let(:parent_path_real_path) do
          nil
        end

        it { should be_nil }
      end
    end

    context 'without parent_path' do
      let(:parent_path) do
        nil
      end

      it { should be_nil }
    end
  end

  context '#derived_real_path_modified_at' do
    subject(:derived_real_path_modified_at) do
      ancestor.derived_real_path_modified_at
    end

    let(:ancestor) do
      FactoryGirl.build(:mdm_module_ancestor)
    end

    context 'with real_path' do
      before(:each) do
        ancestor.real_path = real_path
      end

      context 'that exists' do
        let(:real_path) do
          # derived real path will have been created by factory's after(:build)
          ancestor.derived_real_path
        end

        it 'should be modification time of file' do
          derived_real_path_modified_at.should == File.mtime(real_path)
        end

        it 'should be in UTC' do
          derived_real_path_modified_at.zone.should == 'UTC'
        end
      end

      context 'that does not exist' do
        let(:real_path) do
          'non/existent/path'
        end

        it { should be_nil }
      end
    end

    context 'without real_path' do
      it 'should have nil for real_path' do
        ancestor.real_path.should be_nil
      end

      it { should be_nil }
    end
  end

  context '#derived_real_path_sha1_hex_digest' do
    subject(:derived_real_path_sha1_hex_digest) do
      ancestor.derived_real_path_sha1_hex_digest
    end

    let(:ancestor) do
      FactoryGirl.build(:mdm_module_ancestor)
    end

    context 'with real_path' do
      before(:each) do
        ancestor.real_path = ancestor.derived_real_path
      end

      context 'that exists' do
        it 'should read the using Digest::SHA1.file' do
          Digest::SHA1.should_receive(:file).with(ancestor.real_path).and_call_original

          derived_real_path_sha1_hex_digest
        end

        context 'with content' do
          let(:content_sha1_hex_digest) do
            Digest::SHA1.hexdigest(content)
          end

          before(:each) do
            File.open(ancestor.real_path, 'wb') do |f|
              f.write(content)
            end
          end

          context 'that is empty' do
            let(:content) do
              ''
            end

            it 'should have empty file at real_path' do
              File.size(ancestor.real_path).should be_zero
            end

            it 'should have SHA1 hex digest for empty string' do
              derived_real_path_sha1_hex_digest.should == content_sha1_hex_digest
            end
          end

          context 'that is not empty' do
            let(:content) do
              "# Non-empty content"
            end

            it 'should have SHA1 hex digest for content' do
              derived_real_path_sha1_hex_digest.should == content_sha1_hex_digest
            end
          end
        end
      end

      context 'that does not exist' do
        before(:each) do
          File.delete(ancestor.real_path)
        end

        it { should be_nil }
      end
    end

    context 'without real_path' do
      it 'should have nil for real_path' do
        ancestor.real_path.should be_nil
      end

      it { should be_nil }
    end
  end

  # class method
  context 'handled?' do
    subject(:handled?) do
      described_class.handled?(
          :module_type => module_type,
          :payload_type => payload_type
      )
    end

    context 'with module_type' do
      context 'payload' do
        let(:module_type) do
          'payload'
        end

        context 'with payload_type' do
          context 'single' do
            let(:payload_type) do
              'single'
            end

            it { should be_true }
          end

          context 'stage' do
            let(:payload_type) do
              'stage'
            end

            it { should be_false }
          end

          context 'stager' do
            let(:payload_type) do
              'stager'
            end

            it { should be_true }
          end
        end

        context 'without payload_type' do
          let(:payload_type) do
            nil
          end

          it { should be_false }
        end
      end

      context 'non-payload' do
        let(:module_type) do
          FactoryGirl.generate :mdm_module_ancestor_non_payload_module_type
        end

        context 'with payload_type' do
          context 'single' do
            let(:payload_type) do
              'single'
            end

            it { should be_false }
          end

          context 'stage' do
            let(:payload_type) do
              'stage'
            end

            it { should be_false }
          end

          context 'stager' do
            let(:payload_type) do
              'stager'
            end

            it { should be_false }
          end
        end

        context 'without payload_type' do
          let(:payload_type) do
            nil
          end

          it { should be_false }
        end
      end
    end

    context 'without module_type' do
      let(:module_type) do
        nil
      end

      context 'with payload_type' do
        context 'single'  do
          let(:payload_type) do
            'single'
          end

          it { should be_false }
        end

        context 'stage' do
          let(:payload_type) do
            'stage'
          end

          it { should be_false }
        end

        context 'stager' do
          let(:payload_type) do
            'stager'
          end

          it { should be_false }
        end
      end

      context 'without payload_type' do
        let(:payload_type) do
          nil
        end

        it { should be_false }
      end
    end
  end

  # instance method
  context '#handled?' do
    subject(:handled?) do
      ancestor.handled?
    end

    let(:ancestor) do
      FactoryGirl.build(
          :mdm_module_ancestor,
          :module_type => module_type,
          :payload_type => payload_type
      )
    end

    let(:module_type) do
      'payload'
    end

    let(:payload_type) do
      FactoryGirl.generate :mdm_module_ancestor_payload_type
    end

    before(:each) do
      ancestor.payload_type = ancestor.derived_payload_type
    end

    it 'should delegate to class method' do
      described_class.should_receive(:handled?).with(
          :module_type => module_type,
          :payload_type => payload_type
      )

      handled?
    end
  end

  context '#payload?' do
    subject(:ancestor) do
      described_class.new(:module_type => module_type)
    end

    context "with 'payload' module_type" do
      let(:module_type) do
        'payload'
      end

      it { should be_payload }
    end

    context "without 'payload' module_type" do
      let(:module_type) do
        FactoryGirl.generate :mdm_module_ancestor_non_payload_module_type
      end

      it { should_not be_payload }
    end
  end

  context '#reference_path' do
    subject(:reference_path) do
      ancestor.reference_path
    end

    let(:ancestor) do
      described_class.new(
          :reference_name => reference_name
      )
    end

    context 'with reference_name' do
      let(:reference_name) do
        FactoryGirl.generate :mdm_module_ancestor_non_payload_reference_name
      end

      it 'should be reference_name + EXTENSION' do
        reference_path.should == "#{reference_name}#{described_class::EXTENSION}"
      end
    end

    context 'without reference_name' do
      let(:reference_name) do
        nil
      end

      it { should be_nil }
    end
  end

  context '#module_type_directory' do
    subject(:module_type_directory) do
      ancestor.module_type_directory
    end

    let(:ancestor) do
      described_class.new(
          :module_type => module_type
      )
    end

    context 'with module_type' do
      context 'in known types' do
        let(:module_type) do
          FactoryGirl.generate :mdm_module_ancestor_module_type
        end

        it 'should use Metasploit::Model::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE' do
          module_type_directory.should == Metasploit::Model::Module::Ancestor::DIRECTORY_BY_MODULE_TYPE[module_type]
        end
      end

      context 'in unknown types' do
        let(:module_type) do
          'not_a_type'
        end

        it { should be_nil }
      end
    end

    context 'without module_type' do
      let(:module_type) do
        nil
      end

      it { should be_nil }
    end
  end
end