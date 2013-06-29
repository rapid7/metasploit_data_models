require 'spec_helper'

describe Mdm::TaskHost do

  context 'factory' do
    it 'should be valid' do
      task_host = FactoryGirl.build(:mdm_task_host)
      task_host.should be_valid
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:task_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:host_id).of_type(:integer).with_options(:null => false) }


      context 'timestamps'do
        it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
        it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
      end
    end

    context 'indices' do
      it { should have_db_index([:task_id, :host_id]).unique(true) }
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      task_host = FactoryGirl.create(:mdm_task_host)
      expect {
        task_host.destroy
      }.to_not raise_error
      expect {
        task_host.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "Associations" do
    it { should belong_to(:task).class_name('Mdm::Task') }
    it { should belong_to(:host).class_name('Mdm::Host') }
  end

  context "validations" do
    it { should validate_presence_of :host }

    it "should not allow duplicate associations" do
      task = FactoryGirl.build(:mdm_task)
      host = FactoryGirl.build(:mdm_host)
      FactoryGirl.create(:mdm_task_host, :task => task, :host => host)
      task_host2 = FactoryGirl.build(:mdm_task_host, :task => task, :host => host)
      task_host2.should_not be_valid
    end

    it { should validate_presence_of :task }
  end
end
