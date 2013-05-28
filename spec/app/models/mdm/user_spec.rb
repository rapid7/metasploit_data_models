require 'spec_helper'

describe Mdm::User do

  context 'associations' do
    it { should have_many(:owned_workspaces).class_name('Mdm::Workspace') }
    it { should have_many(:tags).class_name('Mdm::Tag') }
    it { should have_and_belong_to_many(:workspaces).class_name('Mdm::Workspace') }
  end

  context 'factory' do
    it 'should be valid' do
      user = FactoryGirl.build(:mdm_user)
      user.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      user = FactoryGirl.create(:mdm_user)
      expect {
        user.destroy
      }.to_not raise_error
      expect {
        user.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end