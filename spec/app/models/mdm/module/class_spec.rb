require 'spec_helper'

describe Mdm::Module::Class do
  subject(:module_class) do
    FactoryGirl.build(:mdm_module_class)
  end

  let(:staged_ancestor_payload_types) do
    [
        'stage',
        'stager'
    ]
  end

  context 'associations' do
    it { should have_many(:ancestors).class_name('Mdm::Module::Ancestor').through(:relationships) }
    it { should have_one(:module_instance).class_name('Mdm::Module::Instance').dependent(:destroy) }
    it { should belong_to(:rank).class_name('Mdm::Module::Rank') }
    it { should have_many(:relationships).class_name('Mdm::Module::Relationship').dependent(:destroy).with_foreign_key(:descendant_id) }
  end

  context 'CONSTANTS' do
    context 'PAYLOAD_TYPES' do
      subject(:payload_types) do
        described_class::PAYLOAD_TYPES
      end

      it { should include('single') }
      it { should include('staged') }
    end

    context 'STAGED_ANCESTOR_PAYLOAD_TYPES' do
      it 'should be defined in any order' do
        described_class::STAGED_ANCESTOR_PAYLOAD_TYPES.should =~ staged_ancestor_payload_types
      end
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:full_name).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:module_type).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:payload_type).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:rank_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:reference_name).of_type(:text).with_options(:null => false) }
    end

    context 'indices' do
      context 'foreign key' do
        it { should have_db_column(:rank_id) }
      end

      context 'unique' do
        it { should have_db_index(:full_name).unique(true) }
        it { should have_db_index([:module_type, :reference_name]).unique(true) }
      end
    end
  end

  context 'derivations' do
    context 'with module_type derived' do
      before(:each) do
        module_class.module_type = module_class.derived_module_type
      end

      context 'with payload_type derived' do
        before(:each) do
          module_class.payload_type = module_class.derived_payload_type
        end

        context 'with payload module_type' do
          subject(:module_class) do
            FactoryGirl.build(
                :mdm_module_class,
                :module_type => 'payload'
            )
          end

          it_should_behave_like 'derives', :payload_type, :validates => true
          it_should_behave_like 'derives', :reference_name, :validates => true

          context 'with payload_type derived' do
            before(:each) do
              module_class.payload_type = module_class.derived_payload_type
            end

            context 'with reference_name derived' do
              before(:each) do
                module_class.reference_name = module_class.derived_reference_name
              end

              it_should_behave_like 'derives', :full_name, :validates => true
            end
          end
        end
      end

      context 'without payload module_type' do
        subject(:module_class) do
          FactoryGirl.build(
              :mdm_module_class,
              :module_type => module_type
          )
        end

        let(:module_type) do
          FactoryGirl.generate :mdm_module_class_non_payload_module_type
        end

        it_should_behave_like 'derives', :reference_name, :validates => true

        context 'with reference_name derived' do
          before(:each) do
            module_class.reference_name = module_class.derived_reference_name
          end

          it_should_behave_like 'derives', :full_name, :validates => true
        end
      end
    end

    it_should_behave_like 'derives', :module_type, :validates => true
  end

  context 'factories' do
    context 'mdm_module_class' do
      subject(:mdm_module_class) do
        FactoryGirl.build(:mdm_module_class)
      end

      it { should be_valid }

      context 'destroying' do
        before(:each) do
          mdm_module_class.save!
        end

        it 'should not destroy Mdm::Module::Ancestors' do
          expect {
            mdm_module_class.destroy
          }.to_not change(Mdm::Module::Ancestor, :count)
        end

        it 'should destroy Mdm::Module::Class' do
          expect {
            mdm_module_class.destroy
          }.to change(Mdm::Module::Class, :count).by(-1)
        end

        it 'should destroy Mdm::Module::Relationship(s)' do
          expect {
            mdm_module_class.destroy
          }.to change(Mdm::Module::Relationship, :count).by_at_most(mdm_module_class.relationships.count)
        end
      end

      context 'saving' do
        it 'should create Mdm::Module::Ancestor(s)' do
          expect {
            mdm_module_class.save!
          }.to change(Mdm::Module::Ancestor, :count).by_at_least(1)
        end

        it 'should create Mdm::Module::Class' do
          expect {
            mdm_module_class.save!
          }.to change(Mdm::Module::Class, :count).by(1)
        end

        it 'should create Mdm::Module::Relationship' do
          expect {
            mdm_module_class.save!
          }.to change(Mdm::Module::Relationship, :count).by_at_least(1)
        end
      end

      context 'module_type' do
        subject(:mdm_module_class) do
          FactoryGirl.build(
              :mdm_module_class,
              :module_type => module_type
          )
        end

        context 'with payload' do
          let(:module_type) do
            'payload'
          end

          it { should be_valid }

          context 'with payload_type' do
            subject(:mdm_module_class) do
              FactoryGirl.build(
                  :mdm_module_class,
                  :module_type => module_type,
                  :payload_type => payload_type
              )
            end

            context 'single' do
              let(:payload_type) do
                'single'
              end

              it { should be_valid }

              context 'destroying' do
                before(:each) do
                  mdm_module_class.save!
                end

                it 'should not destroy Mdm::Module::Ancestor' do
                  expect {
                    mdm_module_class.destroy
                  }.to_not change(Mdm::Module::Ancestor, :count)
                end

                it 'should destroy Mdm::Module::Class' do
                  expect {
                    mdm_module_class.destroy
                  }.to change(Mdm::Module::Class, :count).by(-1)
                end

                it 'shoudl destroy Mdm::Module::Relationship' do
                  expect {
                    mdm_module_class.destroy
                  }.to change(Mdm::Module::Relationship, :count).by(-1)
                end
              end

              context 'saving' do
                it 'should create Mdm::Module::Ancestor' do
                  expect {
                    mdm_module_class.save!
                  }.to change(Mdm::Module::Ancestor, :count).by(1)
                end

                it 'should create Mdm::Module::Class' do
                  expect {
                    mdm_module_class.save!
                  }.to change(Mdm::Module::Class, :count).by(1)
                end

                it 'should create Mdm::Module::Relationship' do
                  expect {
                    mdm_module_class.save!
                  }.to change(Mdm::Module::Relationship, :count).by(1)
                end
              end
            end

            context 'staged' do
              let(:payload_type) do
                'staged'
              end

              it { should be_valid }

              context 'destroying' do
                before(:each) do
                  mdm_module_class.save!
                end

                it 'should not destroy Mdm::Module::Ancestor' do
                  expect {
                    mdm_module_class.destroy
                  }.to_not change(Mdm::Module::Ancestor, :count)
                end

                it 'should destroy Mdm::Module::Class' do
                  expect {
                    mdm_module_class.destroy
                  }.to change(Mdm::Module::Class, :count).by(-1)
                end

                it 'should destroy Mdm::Module::Relationships' do
                  expect {
                    mdm_module_class.destroy
                  }.to change(Mdm::Module::Relationship, :count).by(-2)
                end
              end

              context 'saving' do
                it 'should create Mdm::Module::Ancestors' do
                  expect {
                    mdm_module_class.save!
                  }.to change(Mdm::Module::Ancestor, :count).by(2)
                end

                it 'should create Mdm::Module::Class' do
                  expect {
                    mdm_module_class.save!
                  }.to change(Mdm::Module::Class, :count).by(1)
                end

                it 'should create Mdm::Module::Relationships' do
                  expect {
                    mdm_module_class.save!
                  }.to change(Mdm::Module::Relationship, :count).by(2)
                end
              end
            end

            context 'other' do
              let(:payload_type) do
                'not_a_payload_type'
              end

              it 'should raise ArgumentError' do
                expect {
                  mdm_module_class
                }.to raise_error(ArgumentError)
              end
            end
          end
        end

        context 'without payload' do
          let(:module_type) do
            FactoryGirl.generate :mdm_module_class_non_payload_module_type
          end

          it { should be_valid }

          its(:derived_module_type) { should == module_type }

          context 'destroying' do
            before(:each) do
              mdm_module_class.save!
            end

            it 'should not destroy Mdm::Module::Ancestor' do
              expect {
                mdm_module_class.destroy
              }.to_not change(Mdm::Module::Ancestor, :count)
            end

            it 'should destroy Mdm::Module::Class' do
              expect {
                mdm_module_class.destroy
              }.to change(Mdm::Module::Class, :count).by(-1)
            end

            it 'should destroy Mdm::Module::Relationship' do
              expect {
                mdm_module_class.destroy
              }.to change(Mdm::Module::Relationship, :count).by(-1)
            end
          end

          context 'saving' do
            it 'should create Mdm::Module::Ancestor' do
              expect {
                mdm_module_class.save!
              }.to change(Mdm::Module::Ancestor, :count).by(1)
            end

            it 'should create Mdm::Module::Class' do
              expect {
                mdm_module_class.save!
              }.to change(Mdm::Module::Class, :count).by(1)
            end

            it 'should create Mdm::Module::Relationship' do
              expect {
                mdm_module_class.save!
              }.to change(Mdm::Module::Relationship, :count).by(1)
            end
          end
        end
      end

      context 'ancestors' do
        subject(:mdm_module_class) do
          FactoryGirl.build(
              :mdm_module_class,
              :ancestors => ancestors
          )
        end

        context 'single payload' do
          let!(:ancestors) do
            [
              FactoryGirl.create(:single_payload_mdm_module_ancestor)
            ]
          end

          it { should be_valid }

          it 'should not create any Mdm::Module::Ancestors' do
            expect {
              mdm_module_class
            }.to_not change(Mdm::Module::Ancestor, :count)
          end
        end

        context 'stage payload and stager payload' do
          let!(:ancestors) do
            [
                FactoryGirl.create(:stage_payload_mdm_module_ancestor),
                FactoryGirl.create(:stager_payload_mdm_module_ancestor)
            ]
          end

          it { should be_valid }

          it 'should not create any Mdm::Module::Ancestors' do
            expect {
              mdm_module_class
            }.to_not change(Mdm::Module::Ancestor, :count)
          end
        end
      end
    end
  end

  context 'validations' do
    context 'ancestors' do
      context 'count' do
        subject(:module_class) do
          FactoryGirl.build(
              :mdm_module_class,
              :ancestors => ancestors,
              :module_type => module_type,
              :payload_type => payload_type
          )
        end

        before(:each) do
          # set explicitly so derivation doesn't cause other code path to run
          module_class.module_type = module_type
        end

        context 'with payload module_type' do
          let(:module_type) do
            'payload'
          end

          before(:each) do
            # set explicitly so derivation doesn't cause other code path to run
            module_class.payload_type = payload_type

            module_class.valid?
          end

          context 'with single payload_type' do
            let(:error) do
              'must have exactly one ancestor for single payload module class'
            end

            let(:payload_type) do
              'single'
            end


            context 'with 1 ancestor' do
              let(:ancestors) do
                [
                    FactoryGirl.create(:single_payload_mdm_module_ancestor)
                ]
              end

              it 'should not record error on ancestors' do
                module_class.errors[:ancestors].should_not include(error)
              end
            end

            context 'without 1 ancestor' do
              let(:ancestors) do
                []
              end

              it 'should record error on ancestors' do
                module_class.errors[:ancestors].should include(error)
              end
            end
          end

          context 'with staged payload_type' do
            let(:error) do
              'must have exactly two ancestors (stager + stage) for staged payload module class'
            end

            let(:payload_type) do
              'staged'
            end

            context 'with 2 ancestors' do
              let(:ancestors) do
                [
                    FactoryGirl.create(:stage_payload_mdm_module_ancestor),
                    FactoryGirl.create(:stager_payload_mdm_module_ancestor)
                ]
              end

              it 'should not record error on ancestors' do
                module_class.errors[:ancestors].should_not include(error)
              end
            end

            context 'without 2 ancestors' do
              let(:ancestors) do
                [
                    FactoryGirl.create(:stage_payload_mdm_module_ancestor)
                ]
              end

              it 'should record error on ancestors' do
                module_class.errors[:ancestors].should include(error)
              end
            end
          end
        end

        context 'without payload module_type' do
          let(:error) do
            'must have exactly one ancestor as a non-payload module class'
          end

          let(:module_type) do
            FactoryGirl.generate :mdm_module_class_non_payload_module_type
          end

          let(:payload_type) do
            nil
          end

          before(:each) do
            module_class.valid?
          end

          context 'with 1 ancestor' do
            let(:ancestors) do
              [
                  FactoryGirl.create(:non_payload_mdm_module_ancestor)
              ]
            end

            it 'should not record error on ancestors' do
              module_class.errors[:ancestors].should_not include(error)
            end
          end

          context 'without 1 ancestor' do
            let(:ancestors) do
              module_class.errors[:ancestors].should include(error)
            end
          end
        end
      end

      context 'module_types' do
        context 'between Mdm::Module::Ancestor#module_type and Mdm::Module::Class#module_type' do
          subject(:module_class) do
            FactoryGirl.build(
                :mdm_module_class,
                :module_type => module_type,
                :ancestors => ancestors
            )
          end

          def error(module_class, ancestor)
            "can contain ancestors only with same module_type (#{module_class.module_type}); " \
            "#{ancestor.full_name} cannot be an ancestor due to its module_type (#{ancestor.module_type})"
          end

          before(:each) do
            # Explicitly set module_type so its not derived, which could cause an alternate code path to be tested
            module_class.module_type = module_type

            module_class.valid?
          end

          context 'with module_type' do
            let(:module_type) do
              FactoryGirl.generate :mdm_module_class_module_type
            end

            context 'with same Mdm::Module::Ancestor#module_type and Mdm::Module::Class#module_type' do
              let(:ancestors) do
                [
                    FactoryGirl.create(
                        :mdm_module_ancestor,
                        :module_type => module_type
                    )
                ]
              end

              it 'should not record on ancestors' do
                module_class.errors[:ancestors].should_not include(error(module_class, ancestors.first))
              end
            end

            context 'without same Mdm::Module::Ancestor#module_type and Mdm::Module::Class#module_type' do
              let(:ancestors) do
                [
                    FactoryGirl.create(
                        :mdm_module_ancestor,
                        :module_type => 'exploit'
                    )
                ]
              end

              let(:module_type) do
                'nop'
              end

              it 'should record error on ancestors' do
                module_class.errors[:ancestors].should include(error(module_class, ancestors.first))
              end
            end
          end

          context 'without module_type' do
            # with a nil module_type, module_type will be derived from
            let(:ancestors) do
              [
                  FactoryGirl.create(:mdm_module_ancestor),
                  FactoryGirl.create(:mdm_module_ancestor)
              ]
            end

            let(:module_type) do
              nil
            end

            it 'should not record errors on ancestors' do
              ancestor_errors = module_class.errors[:ancestors]

              ancestors.each do |ancestor|
                ancestor_error = error(module_class, ancestor)

                ancestor_errors.should_not include(ancestor_error)
              end
            end
          end
        end

        context 'between Mdm::Module::Ancestor#module_types' do
          subject(:module_class) do
            FactoryGirl.build(
                :mdm_module_class,
                :ancestors => ancestors
            )
          end

          let(:error) do
            "can only contain ancestors with one module_type, " \
            "but contains multiple module_types (#{module_type_set.sort.to_sentence})"
          end

          before(:each) do
            module_class.valid?
          end

          context 'with same Mdm::Module::Ancestor#module_type' do
            let(:ancestors) do
              [
                  FactoryGirl.create(
                      :mdm_module_ancestor,
                      :module_type => module_type
                  ),
                  FactoryGirl.create(
                      :mdm_module_ancestor,
                      :module_type => module_type
                  )
              ]
            end

            let(:module_type) do
              FactoryGirl.generate :mdm_module_ancestor_module_type
            end

            let(:module_type_set) do
              Set.new [module_type]
            end

            it 'should not record error on ancestors' do
              module_class.errors[:ancestors].should_not include(error)
            end
          end

          context 'without same Mdm::Module::Ancestor#module_type' do
            let(:ancestors) do
              module_type_set.collect { |module_type|
                FactoryGirl.create(
                    :mdm_module_ancestor,
                    :module_type => module_type
                )
              }
            end

            let(:module_types) do
              [
                  FactoryGirl.generate(:mdm_module_ancestor_module_type),
                  FactoryGirl.generate(:mdm_module_ancestor_module_type)
              ]
            end

            let(:module_type_set) do
              Set.new module_types
            end

            it 'should record error on ancestors' do
              module_class.errors[:ancestors].should include(error)
            end
          end
        end
      end

      context 'payload_types' do
        subject(:module_class) do
          FactoryGirl.build(
              :mdm_module_class,
              :ancestors => ancestors,
              :module_type => module_type
          )
        end

        before(:each) do
          # explicitly set module_type so it is not derived from ancestors
          module_class.module_type = module_type
        end

        context "with 'payload' Mdm::Module::Class#module_type" do
          let(:module_type) do
            'payload'
          end

          let(:ancestors) do
            [
                ancestor
            ]
          end

          context 'with Mdm::Module::Class#payload_type' do
            before(:each) do
              # Explicitly set payload_type so it is not derived from ancestors
              module_class.payload_type = payload_type

              module_class.valid?
            end

            context 'single' do
              let(:error) do
                "cannot have an ancestor (#{ancestor.full_name}) " \
                "with payload_type (#{ancestor.payload_type}) " \
                "for class payload_type (#{payload_type})"
              end

              let(:payload_type) do
                'single'
              end

              context "with 'single' Mdm::Module::Ancestor#payload_type" do
                let(:ancestor) do
                  FactoryGirl.create(:single_payload_mdm_module_ancestor)
                end

                it 'should not record error on ancestors' do
                  module_class.errors[:ancestors].should_not include(error)
                end
              end

              context "without 'single' Mdm::Module::Ancestor#payload_type" do
                let(:ancestor) do
                  FactoryGirl.create(:stage_payload_mdm_module_ancestor)
                end

                it 'should record error on ancestors' do
                  module_class.errors[:ancestors].should include(error)
                end
              end
            end

            context 'staged' do
              let(:payload_type) do
                'staged'
              end

              context "Mdm::Module::Ancestor#payload_type" do
                let(:few_error) do
                  "needs exactly one ancestor with payload_type (#{ancestor_payload_type}), " \
                  "but there are none."
                end

                let(:many_error) do
                  "needs exactly one ancestor with payload_type (#{ancestor_payload_type}), " \
                  "but there are #{ancestors.count} (#{ancestors.map(&:full_name).to_sentence})"
                end

                context 'single' do
                  context 'without zero' do
                    let(:ancestor) do
                      FactoryGirl.create(:single_payload_mdm_module_ancestor)
                    end

                    let(:ancestors) do
                      [
                        ancestor
                      ]
                    end

                    let(:error) do
                      "cannot have ancestors (#{ancestor.full_name}) " \
                      "with payload_type (#{ancestor.payload_type}) " \
                      "for class payload_type (#{payload_type}); " \
                      "only one stage and one stager ancestor is allowed"
                    end

                    it 'should record error on ancestors' do
                      module_class.valid?

                      module_class.errors[:ancestors].should include(error)
                    end
                  end
                end

                context 'stage' do
                  let(:ancestor_payload_type) do
                    'stage'
                  end

                  context 'with < 1' do
                    # 1 stager and 0 stages, so stages count < 1
                    let(:ancestors) do
                      [
                        FactoryGirl.create(:stager_payload_mdm_module_ancestor)
                      ]
                    end

                    it 'should record error on ancestors' do
                      module_class.errors[:ancestors].should include(few_error)
                    end
                  end

                  context 'with 1' do
                    # 1 stager and 1 stage, so stages count == 1
                    let(:ancestors) do
                      [
                          FactoryGirl.create(:stager_payload_mdm_module_ancestor),
                          FactoryGirl.create(:stage_payload_mdm_module_ancestor)
                      ]
                    end

                    it 'should not record error on ancestors' do
                      module_class.errors[:ancestors].should_not include(few_error)
                      module_class.errors[:ancestors].should_not include(many_error)
                    end
                  end

                  context 'with > 1' do
                    # 0 stager, 2 stages, so stages count > 1
                    let(:ancestors) do
                      FactoryGirl.create_list(:stage_payload_mdm_module_ancestor, 2)
                    end

                    it 'should record error on ancestors' do
                      module_class.errors[:ancestors].should include(many_error)
                    end
                  end
                end

                context 'stager' do
                  let(:ancestor_payload_type) do
                    'stager'
                  end

                  context 'with < 1' do
                    # 0 stager and 1 stages, so stagers count < 1
                    let(:ancestors) do
                      [
                        FactoryGirl.create(:stage_payload_mdm_module_ancestor)
                      ]
                    end

                    it 'should record error on ancestors' do
                      module_class.errors[:ancestors].should include(few_error)
                    end
                  end

                  context 'with 1' do
                    # 1 stager and 1 stage, so stagers count == 1
                    let(:ancestors) do
                      [
                          FactoryGirl.create(:stager_payload_mdm_module_ancestor),
                          FactoryGirl.create(:stage_payload_mdm_module_ancestor)
                      ]
                    end

                    it 'should not record error on ancestors' do
                      module_class.errors[:ancestors].should_not include(few_error)
                      module_class.errors[:ancestors].should_not include(many_error)
                    end
                  end

                  context 'with > 1' do
                    # 2 stagers, 0 stages, so stagers count > 1
                    let(:ancestors) do
                      FactoryGirl.create_list(:stager_payload_mdm_module_ancestor, 2)
                    end

                    it 'should record error on ancestors' do
                      module_class.errors[:ancestors].should include(many_error)
                    end
                  end
                end
              end
            end
          end
        end

        context "without 'payload' Mdm::Module::Class#module_type" do
          let(:ancestors) do
            [
                ancestor
            ]
          end

          let(:error) do
            "cannot have an ancestor (#{ancestor.full_name}) " \
            "with a payload_type (#{ancestor.payload_type}) " \
            "for class module_type (#{module_type})"
          end

          let(:module_type) do
            FactoryGirl.generate :mdm_module_class_non_payload_module_type
          end

          before(:each) do
            module_class.valid?
          end

          context 'with Mdm::Module::Ancestor#payload_type' do
            let(:ancestor) do
              FactoryGirl.create(:payload_mdm_module_ancestor)
            end

            it 'should record error on ancestors' do
              module_class.errors[:ancestors].should include(error)
            end
          end

          context 'without Mdm::Module::Ancestore#payload_type' do
            let(:ancestor) do
              FactoryGirl.create(:non_payload_mdm_module_ancestor)
            end

            it 'should not record error on ancestors' do
              module_class.errors[:ancestors].should_not include(error)
            end
          end
        end
      end
    end

    context 'validates module_type inclusion in Mdm::Module::Ancestor::MODULE_TYPES' do
      subject(:module_class) do
        FactoryGirl.build(
            :mdm_module_class,
            :ancestors => [],
            :module_type => module_type
        )
      end

      let(:error) do
        'is not included in the list'
      end

      before(:each) do
        module_class.module_type = module_type
      end

      Metasploit::Model::Module::Type::ALL.each do |context_module_type|
        context "with #{context_module_type}" do
          let(:module_type) do
            context_module_type
          end

          it 'should not record error on module_type' do
            module_class.valid?

            module_class.errors[:module_type].should_not include(error)
          end
        end
      end

      context 'without module_type' do
        let(:module_type) do
          nil
        end

        it { should_not be_valid }

        it 'should record error on module_type' do
          module_class.valid?

          module_class.errors[:module_type].should include(error)
        end
      end
    end

    context 'payload_type' do
      subject(:module_class) do
        FactoryGirl.build(
            :mdm_module_class,
            :module_type => module_type
        )
      end

      before(:each) do
        module_class.payload_type = payload_type
      end

      context 'with payload' do
        let(:module_type) do
          'payload'
        end

        context 'with payload_type' do
          subject(:module_class) do
            FactoryGirl.build(
                :mdm_module_class,
                # Set explicitly so not derived from module_type and payload_type in factory, which will fail for the
                # invalid payload_type test.
                :ancestors => [],
                :module_type => module_type,
                :payload_type => payload_type
            )
          end

          let(:error) do
            'is not in list'
          end

          before(:each) do
            # Set explicitly so not derived
            module_class.payload_type = payload_type
          end

          context 'single' do
            let(:payload_type) do
              'single'
            end

            it 'should not record error' do
              module_class.valid?

              module_class.errors[:payload_type].should_not include(error)
            end
          end

          context 'staged' do
            let(:payload_type) do
              'staged'
            end

            it 'should not record error on payload_type' do
              module_class.valid?

              module_class.errors[:payload_type].should_not include(error)
            end
          end

          context 'other' do
            let(:payload_type) do
              'invalid_payload_type'
            end

            it 'should record error on payload_type' do
              module_class.valid?

              module_class.errors[:payload_type].should_not be_empty
            end
          end
        end
      end

      context 'without payload' do
        let(:error) do
          'must be nil'
        end

        let(:module_type) do
          FactoryGirl.generate :mdm_module_class_non_payload_module_type
        end

        before(:each) do
          module_class.payload_type = payload_type
        end

        context 'with payload_type' do
          let(:payload_type) do
            FactoryGirl.generate :mdm_module_class_payload_type
          end

          it 'should record error on payload_type' do
            module_class.valid?

            module_class.errors[:payload_type].should include(error)
          end
        end

        context 'without payload_type' do
          let(:payload_type) do
            nil
          end

          it 'should not error on payload_type' do
            module_class.valid?

            module_class.errors[:payload_type].should_not include(error)
          end

        end
      end
    end

    it { should validate_presence_of(:rank) }

    context 'with nil derived_reference_name' do
      before(:each) do
        module_class.stub(:derived_reference_name => nil)
      end

      it { should validate_presence_of(:reference_name) }
    end
  end

  context '#derived_module_type' do
    subject(:derived_module_type) do
      module_class.derived_module_type
    end

    context 'ancestors' do
      before(:each) do
        module_class.ancestors = ancestors
      end

      context 'empty' do
        let(:ancestors) do
          []
        end

        it { should be_nil }
      end

      context 'non-empty' do
        context 'with same Mdm::Module::Ancestor#module_type' do
          let(:ancestors) do
            FactoryGirl.create_list(:mdm_module_ancestor, 2, :module_type => module_type)
          end

          let(:module_type) do
            FactoryGirl.generate :mdm_module_ancestor_module_type
          end

          it 'should return shared module_type' do
            derived_module_type.should == module_type
          end
        end

        context 'with different Mdm::Module;:Ancestor#module_type' do
          let(:ancestors) do
            FactoryGirl.create_list(:mdm_module_ancestor, 2)
          end

          it 'should return nil because there is no consensus' do
            derived_module_type.should be_nil
          end
        end
      end
    end
  end

  context '#derived_payload_type' do
    subject(:derived_payload_type) do
      module_class.derived_payload_type
    end

    before(:each) do
      module_class.module_type = module_type
    end

    context 'with payload' do
      let(:module_type) do
        'payload'
      end

      before(:each) do
        module_class.ancestors = ancestors
      end

      context 'with 1 ancestor' do
        let(:ancestors) do
          [
              FactoryGirl.create(
                  :mdm_module_ancestor,
                  :module_type => 'payload',
                  :payload_type => payload_type
              )
          ]
        end

        context 'with single' do
          let(:payload_type) do
            'single'
          end

          it { should == 'single' }
        end

        context 'without single' do
          let(:payload_type) do
            'stage'
          end

          it { should be_nil }
        end
      end

      context 'with 2 ancestors' do
        context 'with stager and stage' do
          let(:ancestors) do
            ['stager', 'stage'].collect { |payload_type|
                FactoryGirl.create(
                    :payload_mdm_module_ancestor,
                    :payload_type => payload_type
                )
            }
          end

          it { should == 'staged' }
        end

        context 'without stager and stage' do
          let(:ancestors) do
            FactoryGirl.create_list(
                :payload_mdm_module_ancestor,
                2,
                :payload_type => 'stage'
            )
          end

          it { should be_nil }
        end
      end
    end

    context 'without payload' do
      let(:module_type) do
        FactoryGirl.generate :mdm_module_class_non_payload_module_type
      end
    end
  end

  context '#derived_reference_name' do
    subject(:derived_reference_name) do
      module_class.derived_reference_name
    end

    before(:each) do
      module_class.module_type = module_type
    end

    context 'with payload' do
      let(:module_type) do
        'payload'
      end

      before(:each) do
        module_class.payload_type = payload_type
      end

      context 'with single' do
        let(:payload_type) do
          'single'
        end

        it 'should call #derived_single_payload_reference_name' do
          module_class.should_receive(:derived_single_payload_reference_name)

          derived_reference_name
        end
      end

      context 'with staged' do
        let(:payload_type) do
          'staged'
        end

        it 'should call #derived_staged_payload_reference_name' do
          module_class.should_receive(:derived_staged_payload_reference_name)

          derived_reference_name
        end
      end

      context 'without single or staged' do
        let(:payload_type) do
          'invalid_payload_type'
        end

        it { should be_nil }
      end
    end

    context 'without payload' do
      let(:module_type) do
        FactoryGirl.generate :mdm_module_class_non_payload_module_type
      end

      before(:each) do
        module_class.ancestors = ancestors
      end

      context 'with 1 ancestor' do
        let(:ancestor) do
          FactoryGirl.create(:non_payload_mdm_module_ancestor)
        end

        let(:ancestors) do
          [
              ancestor
          ]
        end

        it 'should return reference_name of ancestor' do
          derived_reference_name.should == ancestor.reference_name
        end
      end

      context 'without 1 ancestor' do
        let(:ancestors) do
          FactoryGirl.create_list(:mdm_module_ancestor, 2)
        end

        it { should be_nil }
      end
    end
  end

  context '#derived_single_payload_reference_name' do
    subject(:derived_single_payload_reference_name) do
      module_class.send(:derived_single_payload_reference_name)
    end

    before(:each) do
      module_class.ancestors = ancestors
    end

    context 'with 1 ancestor' do
      let(:ancestor) do
        FactoryGirl.create(
            :payload_mdm_module_ancestor,
            :payload_type => payload_type
        )
      end

      let(:ancestors) do
        [
            ancestor
        ]
      end

      context 'with single' do
        let(:payload_type) do
          'single'
        end

        before(:each) do
          ancestor.reference_name = reference_name
        end

        context 'with reference_name' do
          let(:reference_name) do
            "payload/singles/reference/name"
          end

          before(:each) do
            ancestor.handler_type = handler_type
          end

          context 'with handler_type' do
            let(:handler_type) do
              FactoryGirl.generate :mdm_module_ancestor_handler_type
            end

            it 'should return <reference_name>/<handler_type>' do
              derived_single_payload_reference_name.should == "#{reference_name}/#{handler_type}"
            end
          end

          context 'without handler_type' do
            let(:handler_type) do
              nil
            end

            it { should be_nil }
          end
        end

        context 'without reference_name' do
          let(:reference_name) do
            nil
          end
        end

      end

      context 'without single' do
        let(:payload_type) do
          'stage'
        end

        it { should be_nil }
      end
    end

    context 'without 1 ancestor' do
      let(:ancestors) do
        []
      end

      it { should be_nil }
    end
  end

  context '#derived_staged_payload_reference_name' do
    subject(:derived_staged_payload_reference_name) do
      module_class.send(:derived_staged_payload_reference_name)
    end

    before(:each) do
      module_class.ancestors = ancestors
    end

    context 'with 2 ancestors' do
      context 'with 1 stage' do
        let(:stage_ancestor) do
          FactoryGirl.create(:stage_payload_mdm_module_ancestor)
        end

        before(:each) do
          stage_ancestor.reference_name = stage_reference_name
        end

        context 'with reference_name' do
          let(:stage_reference_name) do
            "payload/stages/reference/name"
          end

          context 'with 1 stager' do
            let(:ancestors) do
              [
                  stager_ancestor,
                  stage_ancestor
              ]
            end

            let(:stager_ancestor) do
              FactoryGirl.create(:stager_payload_mdm_module_ancestor)
            end

            before(:each) do
              stager_ancestor.handler_type = stager_handler_type
            end

            context 'with handler_type' do
              let(:stager_handler_type) do
                FactoryGirl.generate :mdm_module_ancestor_handler_type
              end

              it 'should be <stage.reference_name>/<stager.handler_type>' do
                derived_staged_payload_reference_name.should == "#{stage_reference_name}/#{stager_handler_type}"
              end
            end

            context 'without handler_type' do
              let(:stager_handler_type) do
                nil
              end

              it { should be_nil }
            end
          end

          context 'without 1 stager' do
            let(:ancestors) do
              [
                  stage_ancestor,
                  FactoryGirl.create(:single_payload_mdm_module_ancestor)
              ]
            end

            it { should be_nil }
          end
        end

        context 'without reference_name' do
          let(:ancestors) do
            [
                FactoryGirl.create(:stager_payload_mdm_module_ancestor),
                stage_ancestor
            ]
          end

          let(:stage_reference_name) do
            nil
          end

          it { should be_nil }
        end
      end

      context 'without 1 stage' do
        let(:ancestors) do
          FactoryGirl.create_list(:stager_payload_mdm_module_ancestor, 2)
        end

        it { should be_nil }
      end
    end

    context 'without 2 ancestors' do
      let(:ancestors) do
        FactoryGirl.create_list(:mdm_module_ancestor, 3)
      end

      it { should be_nil }
    end
  end

  context '#payload?' do
    subject(:payload?) do
      module_class.payload?
    end

    # use new instead of factory so that payload? won't be called in the background to show this context supplies
    # coverage
    let(:module_class) do
      described_class.new
    end

    before(:each) do
      module_class.module_type = module_type
    end

    context 'with payload' do
      let(:module_type) do
        'payload'
      end

      it { should be_true }
    end

    context 'without payload' do
      let(:module_type) do
        FactoryGirl.generate :mdm_module_ancestor_non_payload_module_type
      end

      it { should be_false }
    end
  end

  context '#staged_payload_type_count' do
    subject(:staged_payload_type_count) do
      module_class.send(
          :staged_payload_type_count,
          ancestors_by_payload_type,
          ancestor_payload_type
      )
    end

    let(:ancestor_payload_type) do
      FactoryGirl.generate :mdm_module_ancestor_payload_type
    end

    before(:each) do
      staged_payload_type_count
    end

    context 'with ancestors with payload_type' do
      context 'with 1' do
        let(:ancestors_by_payload_type) do
          {
              ancestor_payload_type => FactoryGirl.create_list(
                  :payload_mdm_module_ancestor,
                  1,
                  :payload_type => ancestor_payload_type
              )
          }
        end

        it 'should not record error on ancestors' do
          module_class.errors[:ancestors].should be_empty
        end
      end

      context 'without 1' do
        let(:ancestors_by_payload_type) do
          {
              ancestor_payload_type => payload_type_ancestors
          }
        end

        let(:full_name_sentence) do
          payload_type_ancestors.map(&:full_name).sort.to_sentence
        end

        let(:payload_type_ancestors) do
          FactoryGirl.create_list(
              :payload_mdm_module_ancestor,
              payload_type_ancestor_count,
              :payload_type => ancestor_payload_type
          )
        end

        let(:payload_type_ancestor_count) do
          2
        end

        let(:error) do
          "needs exactly one ancestor with payload_type (#{ancestor_payload_type}), " \
          "but there are #{payload_type_ancestor_count} (#{full_name_sentence})"
        end

        it 'should record error on ancestors' do
          module_class.errors[:ancestors].should include(error)
        end
      end
    end

    context 'without ancestors with payload_type' do
      let(:ancestors_by_payload_type) do
        {}
      end

      let(:error) do
        "needs exactly one ancestor with payload_type (#{ancestor_payload_type}), but there are none."
      end

      it 'should record error on ancestors' do
        module_class.errors[:ancestors].should include(error)
      end
    end
  end
end