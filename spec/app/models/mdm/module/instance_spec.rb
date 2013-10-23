require 'spec_helper'

describe Mdm::Module::Instance do
  subject(:module_instance) do
    FactoryGirl.build(:mdm_module_instance)
  end

  it_should_behave_like 'Metasploit::Model::Module::Instance',
                        namespace_name: 'Mdm'

  context 'associations' do
    it { should have_many(:actions).class_name('Mdm::Module::Action').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:architectures).class_name('Mdm::Architecture').through(:module_architectures) }
    it { should have_many(:authors).class_name('Mdm::Author').through(:module_authors) }
    it { should have_many(:authorities).class_name('Mdm::Authority').through(:references) }
    it { should belong_to(:default_action).class_name('Mdm::Module::Action') }
    it { should belong_to(:default_target).class_name('Mdm::Module::Target') }
    it { should have_many(:email_addresses).class_name('Mdm::EmailAddress').through(:module_authors) }
    it { should have_many(:module_architectures).class_name('Mdm::Module::Architecture').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:module_authors).class_name('Mdm::Module::Author').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should belong_to(:module_class).class_name('Mdm::Module::Class') }
    it { should have_many(:module_platforms).class_name('Mdm::Module::Platform').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:module_references).class_name('Mdm::Module::Reference').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:platforms).class_name('Mdm::Platform').through(:module_platforms) }
    it { should have_one(:rank).class_name('Mdm::Module::Rank').through(:module_class) }
    it { should have_many(:references).class_name('Mdm::Reference').through(:module_references) }
    it { should have_many(:targets).class_name('Mdm::Module::Target').dependent(:destroy).with_foreign_key(:module_instance_id) }
    it { should have_many(:vuln_references).class_name('Mdm::VulnReference').through(:references) }
    it { should have_many(:vulnerable_hosts).class_name('Mdm::Host').through(:vulns) }
    it { should have_many(:vulnerable_services).class_name('Mdm::Service').through(:vulns) }
    it { should have_many(:vulns).class_name('Mdm::Vuln').through(:vuln_references) }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:default_action_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:default_target_id).of_type(:integer).with_options(:null => true) }
      it { should have_db_column(:description).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:disclosed_on).of_type(:date).with_options(:null => true) }
      it { should have_db_column(:license).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:module_class_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:name).of_type(:text).with_options(:null => false) }
      it { should have_db_column(:privileged).of_type(:boolean).with_options(:null => false) }
      it { should have_db_column(:stance).of_type(:string).with_options(:null => true) }
    end

    context 'indices' do
      it { should have_db_index(:default_action_id).unique(true) }
      it { should have_db_index(:default_target_id).unique(true) }
      it { should have_db_index(:module_class_id).unique(true) }
    end
  end
end