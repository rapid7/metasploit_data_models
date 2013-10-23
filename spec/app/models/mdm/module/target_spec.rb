require 'spec_helper'

describe Mdm::Module::Target do
  it_should_behave_like 'Metasploit::Model::Module::Target',
                        namespace_name: 'Mdm'

  context 'associations' do
    it { should belong_to(:module_instance).class_name('Mdm::Module::Instance') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:module_instance_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:index).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:name).of_type(:text).with_options(:null => false) }
    end

    context 'indices' do
      it { should have_db_index([:module_instance_id, :index]).unique(true) }
      it { should have_db_index([:module_instance_id, :name]).unique(true) }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:module_instance_id) }
  end
end