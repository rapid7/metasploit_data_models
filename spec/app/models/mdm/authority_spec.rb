require 'spec_helper'

describe Mdm::Authority do
  it_should_behave_like 'Metasploit::Model::Authority',
                        namespace_name: 'Mdm' do
    def seed_with_abbreviation(abbreviation)
      described_class.where(:abbreviation => abbreviation).first
    end
  end

  context 'associations' do
    it { should have_many(:module_instances).class_name('Mdm::Module::Instance').through(:module_references) }
    it { should have_many(:module_references).class_name('Mdm::Module::Reference').through(:references) }
    it { should have_many(:references).class_name('Mdm::Reference').dependent(:destroy) }
    it { should have_many(:vulns).class_name('Mdm::Vuln').through(:vuln_references) }
    it { should have_many(:vuln_references).class_name('Mdm::VulnReference').through(:references) }
  end

  context 'databases' do
    context 'columns' do
      it { should have_db_column(:abbreviation).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:obsolete).of_type(:boolean).with_options(:default => false, :null => false)}
      it { should have_db_column(:summary).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:url).of_type(:text).with_options(:null => true) }
    end

    context 'indices' do
      it { should have_db_index(:abbreviation).unique(true) }
      it { should have_db_index(:summary).unique(true) }
      it { should have_db_index(:url).unique(true) }
    end
  end

  context 'validations' do
    #
    # lets
    #

    let(:error) do
      I18n.translate!('metasploit.model.errors.messages.taken')
    end

    #
    # let!s
    #

    let!(:existing_authority) do
      FactoryGirl.create(:full_mdm_authority)
    end

    context 'validates uniqueness of abbreviation' do
      context 'with same #abbreviation' do
        let(:new_authority) do
          FactoryGirl.build(
              :mdm_authority,
              abbreviation: existing_authority.abbreviation
          )
        end

        context 'with batched' do
          include_context 'MetasploitDataModels::Batch.batch'

          it 'should not add error on #abbreviation' do
            new_authority.valid?

            new_authority.errors[:abbreviation].should_not include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_authority.save
            }.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end

        context 'without batched' do
          it 'should add error on #abbreviation' do
            new_authority.valid?

            new_authority.errors[:abbreviation].should include(error)
          end
        end
      end
    end

    context 'validates uniqueness of summary' do
      context 'with same #summary' do
        let(:new_authority) do
          FactoryGirl.build(
              :mdm_authority,
              summary: existing_authority.summary
          )
        end

        context 'with batched' do
          include_context 'MetasploitDataModels::Batch.batch'

          it 'should not add error on #summary' do
            new_authority.valid?

            new_authority.errors[:summary].should_not include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_authority.save
            }.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end

        context 'without batched' do
          it 'should add error on #summary' do
            new_authority.valid?

            new_authority.errors[:summary].should include(error)
          end
        end
      end
    end

    context 'validates uniqueness of url' do
      context 'with same #url' do
        let(:new_authority) do
          FactoryGirl.build(
              :mdm_authority,
              url: existing_authority.url
          )
        end

        context 'with batched' do
          include_context 'MetasploitDataModels::Batch.batch'

          it 'should not add error on #url' do
            new_authority.valid?

            new_authority.errors[:url].should_not include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_authority.save
            }.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end

        context 'without batched' do
          it 'should add error on #url' do
            new_authority.valid?

            new_authority.errors[:url].should include(error)
          end
        end
      end
    end
  end
end