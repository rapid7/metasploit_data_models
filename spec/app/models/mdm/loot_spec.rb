require 'spec_helper'

describe Mdm::Loot do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
    it { should belong_to(:service).class_name('Mdm::Service') }
    it { should belong_to(:host).class_name('Mdm::Host') }
    it { should belong_to(:module_run).class_name('MetasploitDataModels::ModuleRun') }
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
    end

    context 'columns' do
      it { should have_db_column(:workspace_id).of_type(:integer).with_options(:null => false, :default =>1) }
      it { should have_db_column(:host_id).of_type(:integer) }
      it { should have_db_column(:service_id).of_type(:integer) }
      it { should have_db_column(:ltype).of_type(:string) }
      it { should have_db_column(:path).of_type(:string) }
      it { should have_db_column(:data).of_type(:text) }
      it { should have_db_column(:content_type).of_type(:string) }
      it { should have_db_column(:name).of_type(:text) }
      it { should have_db_column(:info).of_type(:text) }
    end
  end

  context 'factory' do
    it 'should be valid' do
      loot = FactoryGirl.build(:mdm_loot)
      loot.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      loot = FactoryGirl.create(:mdm_loot)
      expect {
        loot.destroy
      }.to_not raise_error
      expect {
        loot.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'scopes' do
    context 'search' do
      it 'should match on ltype' do
        myloot = FactoryGirl.create(:mdm_loot, :ltype => 'find.this.ltype')
        Mdm::Loot.search('find.this.ltype').should include(myloot)
      end

      it 'should match on name' do
        myloot = FactoryGirl.create(:mdm_loot, :name => 'Find This')
        Mdm::Loot.search('Find This').should include(myloot)
      end

      it 'should match on info' do
        myloot = FactoryGirl.create(:mdm_loot, :info => 'Find This')
        Mdm::Loot.search('Find This').should include(myloot)
      end
    end
  end

  context 'callbacks' do
    context 'before_destroy' do
      it 'should call #delete_file' do
        myloot =  FactoryGirl.create(:mdm_loot)
        myloot.should_receive(:delete_file)
        myloot.destroy
      end
    end
  end
end