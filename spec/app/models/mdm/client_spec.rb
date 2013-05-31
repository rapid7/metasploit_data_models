require 'spec_helper'

describe Mdm::Client do

  context 'associations' do
    it { should belong_to(:host).class_name('Mdm::Host') }
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      client = FactoryGirl.create(:mdm_client, :ua_string => 'user-agent')
      expect {
        client.destroy
      }.to_not raise_error
      expect {
        client.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'factory' do
    it 'should be valid' do
      client = FactoryGirl.build(:mdm_client)
      client.should be_valid
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:host_id).of_type(:integer)}
      it { should have_db_column(:ua_string).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:ua_name).of_type(:string) }
      it { should have_db_column(:ua_ver).of_type(:string) }
    end

    context 'timestamps' do
      it { should have_db_column(:created_at).of_type(:datetime) }
      it { should have_db_column(:updated_at).of_type(:datetime) }
    end

  end

end