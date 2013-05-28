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

end