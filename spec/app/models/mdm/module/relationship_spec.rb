require 'spec_helper'

describe Mdm::Module::Relationship do
  context 'associations' do
    it { should belong_to(:ancestor).class_name('Mdm::Module::Ancestor') }
    it { should belong_to(:descendant).class_name('Mdm::Module::Class') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:ancestor_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:descendant_id).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:ancestor_id, :descendant_id]).unique(true) }
    end
  end

  context 'factories' do
    context 'mdm_module_relationship' do
      subject(:mdm_module_relationship) do
        FactoryGirl.build(:mdm_module_relationship)
      end

      it { should be_valid }
    end
  end

  context 'validations' do
    context 'ancestor' do
      it { should validate_presence_of :ancestor }

      context 'validates uniqueness scoped to descendant_id' do
        let(:error_message) do
          'has already been taken'
        end

        context 'with same descendant_id' do

        end

        context 'with different descendent_id' do

        end
      end
    end

    it { should validate_presence_of :descendant }
  end
end