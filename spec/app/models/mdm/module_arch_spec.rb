require 'spec_helper'

describe Mdm::ModuleArch do
  context 'associations' do
    it { should belong_to(:module_detail).class_name('Mdm::ModuleDetail') }
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
    it { should_not allow_mass_assignment_of(:module_detail_id) }
    it { should allow_mass_assignment_of(:name) }
  end

  context 'validations' do
    it { should validate_presence_of(:module_detail) }
    it { should validate_presence_of(:name) }
  end
end