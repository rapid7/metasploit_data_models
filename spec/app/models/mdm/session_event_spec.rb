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

  context 'database' do
    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime) }
    end

    context 'columns' do
      it { should have_db_column(:session_id).of_type(:integer) }
      it { should have_db_column(:etype).of_type(:string) }
      it { should have_db_column(:command).of_type(:binary) }
      it { should have_db_column(:output).of_type(:binary) }
      it { should have_db_column(:remote_path).of_type(:string) }
      it { should have_db_column(:local_path).of_type(:string) }
    end
  end

end