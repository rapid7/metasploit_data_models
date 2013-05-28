require 'spec_helper'

describe Mdm::SessionEvent do
  context 'associations' do
    it { should belong_to(:session).class_name('Mdm::Session') }
  end

  context 'factory' do
    it 'should be valid' do
      session_event = FactoryGirl.build(:mdm_session_event)
      session_event.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      session_event = FactoryGirl.create(:mdm_session_event)
      expect {
        session_event.destroy
      }.to_not raise_error
      expect {
        session_event.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end