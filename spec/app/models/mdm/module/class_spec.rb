require 'spec_helper'

describe Mdm::Module::Class do
  subject(:module_class) do
    FactoryGirl.build(:mdm_module_class)
  end

  it_should_behave_like 'Metasploit::Model::Module::Class',
                        namespace_name: 'Mdm' do
    def attribute_type(attribute)
      column = module_class_class.columns_hash.fetch(attribute.to_s)

      column.type
    end
  end

  context 'associations' do
    it { should have_many(:ancestors).class_name('Mdm::Module::Ancestor').through(:relationships) }
    it { should have_many(:exploit_attempts).class_name('Mdm::ExploitAttempt').dependent(:destroy) }
    it { should have_many(:exploit_sessions).class_name('Mdm::Session').dependent(:destroy).with_foreign_key(:exploit_class_id) }
    it { should have_one(:module_instance).class_name('Mdm::Module::Instance').dependent(:destroy) }
    it { should have_many(:payload_sessions).class_name('Mdm::Session').dependent(:destroy).with_foreign_key(:payload_class_id) }
    it { should belong_to(:rank).class_name('Mdm::Module::Rank') }
    it { should have_many(:relationships).class_name('Mdm::Module::Relationship').dependent(:destroy).with_foreign_key(:descendant_id) }
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
            FactoryGirl.generate :metasploit_model_non_payload_module_type
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
    #
    # lets
    #

    let(:error) do
      I18n.translate!('metasploit.model.errors.messages.taken')
    end

    let(:existing_module_ancestors) do
      existing_module_class.ancestors
    end

    #
    # let!s
    #

    let!(:existing_module_class) do
      FactoryGirl.create(
          :mdm_module_class
      )
    end

    context 'validates uniqueness of #full_name' do
      context 'with batched' do
        include_context 'MetasploitDataModels::Batch.batch'

        context 'with same #full_name' do
          let(:new_module_class) do
            FactoryGirl.build(
                :mdm_module_class,
                ancestors: existing_module_ancestors
            )
          end

          it 'should not add error on #full_name' do
            new_module_class.valid?

            new_module_class.errors[:full_name].should_not include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_module_class.save
            }.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end
      end

      context 'without batched' do
        context 'with same #full_name' do
          let(:new_module_class) do
            FactoryGirl.build(
                :mdm_module_class,
                ancestors: existing_module_ancestors
            )
          end

          it 'adds error on #full_name' do
            new_module_class.valid?

            new_module_class.errors[:full_name].should include(error)
          end
        end
      end
    end

    context 'validates uniqueness of #reference_name scoped to #module_type'
  end
end