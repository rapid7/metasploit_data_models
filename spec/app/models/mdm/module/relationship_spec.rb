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
      it { should have_db_index([:descendant_id, :ancestor_id]).unique(true) }
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
    it { should validate_presence_of :ancestor }

    # Can't use validate_uniqueness_of(:ancestor_id).scoped_to(:descendant_id) because it will attempt to
    # INSERT with NULL descendant_id, which is invalid.
    context 'validate uniqueness of ancestor_id scoped to descendant_id' do
      let(:existing_descendant) do
        FactoryGirl.create(:mdm_module_class)
        end

      let(:existing_ancestor) do
        FactoryGirl.create(:mdm_module_ancestor)
      end

      let!(:existing_relationship) do
        FactoryGirl.create(
            :mdm_module_relationship,
            :ancestor => existing_ancestor,
            :descendant => existing_descendant
        )
      end

        context 'with same descendant_id' do
        subject(:new_relationship) do
          FactoryGirl.build(
              :mdm_module_relationship,
              :ancestor => existing_ancestor,
              :descendant => existing_descendant
          )
        end

        it { should_not be_valid }

        it 'should record error on ancestor_id' do
          new_relationship.valid?

          new_relationship.errors[:ancestor_id].should include('has already been taken')
        end
      end

      context 'without same descendant_id' do
        subject(:new_relationship) do
          FactoryGirl.build(
              :mdm_module_relationship,
              :ancestor => existing_ancestor,
              :descendant => new_descendant
          )
        end

        let(:new_descendant) do
          FactoryGirl.create :mdm_module_class
        end

        it { should be_valid }
      end
    end

    it { should validate_presence_of :descendant }
  end
end