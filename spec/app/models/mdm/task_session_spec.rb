require 'spec_helper'

describe Mdm::TaskSession do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factory' do
    it 'should be valid' do
      task_session = FactoryGirl.build(:mdm_task_session)
      task_session.should be_valid
    end
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime)}
      it { should have_db_column(:updated_at).of_type(:datetime)}
    end

    context 'columns' do
      it { should have_db_column(:task_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:session_id).of_type(:integer).with_options(:null => false) }
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      task_session = FactoryGirl.create(:mdm_task_session)
      expect {
        task_session.destroy
      }.to_not raise_error
      expect {
        task_session.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "validations" do
    it "should not allow duplicate associations" do
      task = FactoryGirl.build(:mdm_task)
      session = FactoryGirl.build(:mdm_session)
      FactoryGirl.create(:mdm_task_session, :task => task, :session => session)
      task_session2 = FactoryGirl.build(:mdm_task_session, :task => task, :session => session)
      task_session2.should_not be_valid
    end
  end

end
