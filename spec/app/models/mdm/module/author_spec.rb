require 'spec_helper'

describe Mdm::Module::Author do
  subject(:author) do
    FactoryGirl.build(:mdm_module_author)
  end

  context 'associations' do
    it { should belong_to(:detail).class_name('Mdm::Module::Detail') }
  end

  context 'callbacks' do
    context 'before validation' do
      it 'should convert blank email to nil' do
        author.email = ''

        author.email.should be_blank

        author.valid?

        author.email.should be_nil
      end
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:detail_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:name).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:email).of_type(:text).with_options(:null => true) }
    end

    context 'indices' do
      it { should have_db_index(:detail_id) }
    end
  end

  context 'factories' do
    context 'full_mdm_module_author' do
      subject(:full_mdm_module_author) do
        FactoryGirl.build :full_mdm_module_author
      end

      it { should be_valid }
      its(:email) { should_not be_nil }
    end

    context 'mdm_module_author' do
      subject(:mdm_module_author) do
        FactoryGirl.build :mdm_module_author
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:detail_id) }
    it { should allow_mass_assignment_of(:email) }
    it { should allow_mass_assignment_of(:name) }
  end

  context 'validations' do
    it { should validate_presence_of(:detail) }
    it { should_not validate_presence_of(:email) }
    it { should validate_presence_of(:name) }
  end
end