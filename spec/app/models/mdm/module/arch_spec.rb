require 'spec_helper'

describe Mdm::Module::Arch do
  context 'associations' do
    it { should belong_to(:detail).class_name('Mdm::Module::Detail') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:detail_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:name).of_type(:text).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:detail_id, :name]).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_module_arch' do
      subject(:mdm_module_arch) do
        FactoryGirl.build(:mdm_module_arch)
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

    context 'name' do
      it { should validate_presence_of(:name) }

      it_should_behave_like 'validates uniqueness scoped to detail_id',
                            :of => :name,
                            :factory => :mdm_module_arch,
                            :sequence => :mdm_module_arch_name
    end
  end
end