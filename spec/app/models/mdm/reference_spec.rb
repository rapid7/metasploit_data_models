require 'spec_helper'

describe Mdm::Reference do
  it_should_behave_like 'Metasploit::Model::Reference',
                        namespace_name: 'Mdm' do
    include_context 'ActiveRecord attribute_type'

    def authority_with_abbreviation(abbreviation)
      Mdm::Authority.where(:abbreviation => abbreviation).first
    end
  end

  context 'associations' do
    it { should belong_to(:authority).class_name('Mdm::Authority') }
    it { should have_many(:hosts).class_name('Mdm::Host').through(:vulns) }
    it { should have_many(:module_instances).class_name('Mdm::Module::Instance').through(:module_references) }
    it { should have_many(:module_references).class_name('Mdm::Module::Reference').dependent(:destroy) }
    it { should have_many(:services).class_name('Mdm::Service').through(:vulns) }
    it { should have_many(:vulns).class_name('Mdm::Vuln').through(:vuln_references) }
    it { should have_many(:vuln_references).class_name('Mdm::VulnReference').dependent(:destroy) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:authority_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:designation).of_type(:string).with_options(:null => true) }
      it { should have_db_column(:url).of_type(:text).with_options(:null => true) }
    end

    context 'indices' do
      it { should have_db_index([:authority_id, :designation]).unique(true) }
      it { should have_db_index([:url]).unique(true) }
    end
  end

  context 'mass assignment security' do
    it { should_not allow_mass_assignment_of(:authority_id) }
  end
end