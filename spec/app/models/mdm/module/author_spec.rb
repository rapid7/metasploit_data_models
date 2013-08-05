require 'spec_helper'

describe Mdm::Module::Author do
  it_should_behave_like 'Metasploit::Model::Module::Author'

  context 'associations' do
    it { should belong_to(:author).class_name('Mdm::Author') }
    it { should belong_to(:email_address).class_name('Mdm::EmailAddress') }
    it { should belong_to(:module_instance).class_name('Mdm::Module::Instance') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:author_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:email_address_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:module_instance_id).of_type(:integer).with_options(:null => false) }
    end

    context 'indices' do
      context 'foreign key' do
        it { should have_db_index(:author_id) }
        it { should have_db_index(:email_address_id) }
        it { should have_db_index(:module_instance_id) }
      end

      context 'unique' do
        it { should have_db_index([:module_instance_id, :author_id]).unique(true) }
      end
    end
  end

  context 'factories' do
    context 'full_mdm_module_author' do
      subject(:full_mdm_module_author) do
        FactoryGirl.build :full_mdm_module_author
      end

      it { should be_valid }
      its(:email_address) { should_not be_nil }
    end

    context 'mdm_module_author' do
      subject(:mdm_module_author) do
        FactoryGirl.build :mdm_module_author
      end

      it { should be_valid }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:author_id) }
    it { should_not allow_mass_assignment_of(:email_address_id) }
    it { should_not allow_mass_assignment_of(:module_instance_id) }
  end
end