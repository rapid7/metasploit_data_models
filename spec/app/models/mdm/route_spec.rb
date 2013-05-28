require 'spec_helper'

describe Mdm::Route do

  context 'associations' do
    it { should belong_to(:session).class_name('Mdm::Session') }
  end

  context 'factory' do
    it 'should be valid' do
      route = FactoryGirl.build(:mdm_route)
      route.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      route = FactoryGirl.create(:mdm_route)
      expect {
        route.destroy
      }.to_not raise_error
      expect {
        route.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end