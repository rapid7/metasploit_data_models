require 'spec_helper'

describe Mdm::VulnReference do
  context 'associations' do
    it { should belong_to(:reference).class_name('Mdm::Reference') }
    it { should belong_to(:vuln).class_name('Mdm::Vuln') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:reference_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:vuln_id).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:vuln_id, :reference_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_vuln_reference' do
      subject(:mdm_vuln_reference) do
        FactoryGirl.build(:mdm_vuln_reference)
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:reference_id) }
    it { should_not allow_mass_assignment_of(:vuln_id) }
  end

  context 'validations' do
    it { should validate_presence_of(:reference) }

    # Can't use validate_uniqueness_of(:reference_id).scoped_to(:vuln_id) because it will attempt to
    # INSERT with NULL vuln_id, which is invalid.
    context 'validate uniqueness of reference_id scoped to vuln_id' do
      let(:existing_reference) do
        FactoryGirl.create(:mdm_reference)
      end

      let(:existing_vuln) do
        FactoryGirl.create(:mdm_vuln)
      end

      let!(:existing_vuln_reference) do
        FactoryGirl.create(
            :mdm_vuln_reference,
            :reference => existing_reference,
            :vuln => existing_vuln
        )
      end

      context 'with same reference_id' do
        subject(:new_vuln_reference) do
          FactoryGirl.build(
              :mdm_vuln_reference,
              :reference => existing_reference,
              :vuln => existing_vuln
          )
        end

        it { should_not be_valid }

        it 'should record error on reference_id' do
          new_vuln_reference.valid?

          new_vuln_reference.errors[:reference_id].should include('has already been taken')
        end
      end

      context 'without same reference_id' do
        subject(:new_vuln_reference) do
          FactoryGirl.build(
              :mdm_vuln_reference,
              :reference => new_reference,
              :vuln => existing_vuln
          )
        end

        let(:new_reference) do
          FactoryGirl.create(:mdm_reference)
        end

        it { should be_valid }
      end
    end

    it { should validate_presence_of(:vuln) }
  end
end