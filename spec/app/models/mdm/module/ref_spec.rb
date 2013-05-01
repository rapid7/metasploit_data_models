require 'spec_helper'

describe Mdm::Module::Ref do
  context 'associations' do
    it { should belong_to(:detail).class_name('Mdm::Module::Detail') }

    # shoulda matchers don't have support for :primary_key option, so need
    # to test this association manually
    context 'refs' do
      context 'with Mdm::Refs' do
        context 'with same name' do
          let(:name) do
            FactoryGirl.generate :mdm_module_ref_name
          end

          let!(:module_ref) do
            FactoryGirl.create(:mdm_module_ref, :name => name)
          end

          let!(:ref) do
            FactoryGirl.create(:mdm_ref, :name => name)
          end

          it 'should have refs in association' do
            module_ref.refs.should =~ [ref]
          end
        end
      end
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:detail_id).of_type(:integer) }
      it { should have_db_column(:name) }
    end

    context 'indices' do
      it { should have_db_column(:detail_id) }
    end
  end

  context 'factories' do
    context 'mdm_module_ref' do
      subject(:mdm_module_ref) do
        FactoryGirl.build :mdm_module_ref
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:detail_id) }
    it { should allow_mass_assignment_of(:name) }
  end

  context 'validations' do
    it { should validate_presence_of(:detail) }
    it { should validate_presence_of(:name) }
  end
end