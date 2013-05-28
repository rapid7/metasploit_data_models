require 'spec_helper'

describe Mdm::HostDetail do

  context 'associations' do
    it { should belong_to(:host).class_name('Mdm::Host') }
  end

  context 'validations' do
    it 'should only be valid with a host_id' do
      orphan_detail = FactoryGirl.build(:mdm_host_detail, :host => nil)
      orphan_detail.should_not be_valid
      orphan_detail.errors[:host_id].should include("can't be blank")
    end
  end

  context 'factory' do
    it 'should be valid' do
      host_detail = FactoryGirl.build(:mdm_host_detail)
      host_detail.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      detail = FactoryGirl.create(:mdm_host_detail)
      expect{
        detail.destroy
      }.to_not raise_error
      expect {
        detail.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end