require 'spec_helper'

describe Mdm::Module::Reference do
  context 'associations' do
    it { should belong_to(:module_instance).class_name('Mdm::Module::Instance') }
    it { should belong_to(:reference).class_name('Mdm::Reference') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:module_instance_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:reference_id).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:module_instance_id, :reference_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_module_reference' do
      subject(:mdm_module_reference) do
        FactoryGirl.build(:mdm_module_reference)
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:module_instance_id) }
    it { should_not allow_mass_assignment_of(:reference_id) }
  end

  context 'validations' do
    it { should validate_presence_of(:reference) }

    # Can't use validate_uniqueness_of(:reference_id).scoped_to(:module_instance_id) because it will attempt to
    # INSERT with NULL module_instance_id, which is invalid.
    context 'validate uniqueness of reference_id scoped to module_instance_id' do
      let(:existing_module_instance) do
        FactoryGirl.create(:mdm_module_instance)
      end

      let(:existing_reference) do
        FactoryGirl.create(:mdm_reference)
      end

      let!(:existing_module_reference) do
        FactoryGirl.create(
            :mdm_module_reference,
            :module_instance => existing_module_instance,
            :reference => existing_reference
        )
      end

      context 'with same reference_id' do
        subject(:new_module_reference) do
          FactoryGirl.build(
              :mdm_module_reference,
              :module_instance => existing_module_instance,
              :reference => existing_reference
          )
        end

        it { should_not be_valid }

        it 'should record error on reference_id' do
          new_module_reference.valid?

          new_module_reference.errors[:reference_id].should include('has already been taken')
        end
      end

      context 'without same reference_id' do
        subject(:new_module_reference) do
          FactoryGirl.build(
              :mdm_module_reference,
              :module_instance => existing_module_instance,
              :reference => new_reference
          )
        end

        let(:new_reference) do
          FactoryGirl.create(:mdm_reference)
        end

        it { should be_valid }
      end
    end

    it { should validate_presence_of(:module_instance) }
  end
end