require 'spec_helper'

describe Mdm::Reference do
  it_should_behave_like 'Metasploit::Model::Reference',
                        namespace_name: 'Mdm' do
    include_context 'ActiveRecord attribute_type'

    def authority_with_abbreviation(abbreviation)
      Mdm::Authority.where(:abbreviation => abbreviation).first
    end
  end

  context 'associations' do
    it { should belong_to(:authority).class_name('Mdm::Authority') }
    it { should have_many(:hosts).class_name('Mdm::Host').through(:vulns) }
    it { should have_many(:module_instances).class_name('Mdm::Module::Instance').through(:module_references) }
    it { should have_many(:module_references).class_name('Mdm::Module::Reference').dependent(:destroy) }
    it { should have_many(:services).class_name('Mdm::Service').through(:vulns) }
    it { should have_many(:vulns).class_name('Mdm::Vuln').through(:vuln_references) }
    it { should have_many(:vuln_references).class_name('Mdm::VulnReference').dependent(:destroy) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:authority_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:designation).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:url).of_type(:text).with_options(:null => true) }
    end

    context 'indices' do
      it { should have_db_index([:authority_id, :designation]).unique(true) }
      it { should have_db_index([:url]).unique(true) }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:authority_id) }
  end

  context 'validations' do
    #
    # lets
    #

    let(:error) do
      I18n.translate!('metasploit.model.errors.messages.taken')
    end

    let(:existing_authority) do
      existing_reference.authority
    end

    #
    # let!s
    #

    let!(:existing_reference) do
      FactoryGirl.create(:mdm_reference)
    end

    context 'validates #designation scoped to #authority_id' do
      context 'with same #authority_id' do
        let(:new_reference) do
          FactoryGirl.build(
              :mdm_reference,
              authority: existing_authority,
              designation: existing_reference.designation
          )
        end

        context 'with batched' do
          include_context 'MetasploitDataModels::Batch.batch'

          it 'should not add error on #designation' do
            new_reference.valid?

            new_reference.errors[:designation].should_not include(error)
          end

          it 'should raise ActiveRecord::RecordNotUnique when saved' do
            expect {
              new_reference.save
            }.to raise_error(ActiveRecord::RecordNotUnique)
          end
        end

        context 'without batched' do
          it 'should add error on #designation' do
            new_reference.valid?

            new_reference.errors[:designation].should include(error)
          end
        end
      end
    end

    context 'validates uniqueness of #url' do
      let(:new_reference) do
        FactoryGirl.build(
            :mdm_reference,
            url: existing_reference.url
        )
      end

      context 'with batched' do
        include_context 'MetasploitDataModels::Batch.batch'

        it 'should not add error on #url' do
          new_reference.valid?

          new_reference.errors[:url].should_not include(error)
        end

        it 'should raise ActiveRecord::RecordNotUnique when saved' do
          expect {
            new_reference.save
          }.to raise_error(ActiveRecord::RecordNotUnique)
        end
      end

      context 'without batched' do
        it 'should add error on #url' do
          new_reference.valid?

          new_reference.errors[:url].should include(error)
        end
      end
    end
  end
end