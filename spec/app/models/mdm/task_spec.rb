require 'spec_helper'

describe Mdm::Task do

  context 'factory' do
    it 'should be valid' do
      task = FactoryGirl.build(:mdm_task)
      task.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      task = FactoryGirl.create(:mdm_task)
      expect {
        task.destroy
      }.to_not raise_error
      expect {
        task.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context "Associations" do
    it { should have_many(:task_creds).class_name('Mdm::TaskCred').dependent(:destroy) }
    it { should have_many(:creds).class_name('Mdm::Cred').through(:task_creds) }
    it { should have_many(:task_hosts).class_name('Mdm::TaskHost').dependent(:destroy) }
    it { should have_many(:hosts).class_name('Mdm::Host').through(:task_hosts) }
    it { should have_many(:task_services).class_name('Mdm::TaskService').dependent(:destroy) }
    it { should have_many(:services).class_name('Mdm::Service').through(:task_services) }
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
  end

  context 'scopes' do
    context "running" do
      it "should exclude completed tasks" do
        task = FactoryGirl.create(:mdm_task, :completed_at => Time.now)
        Mdm::Task.running.should_not include(task)
      end
    end
  end

  context 'callbacks' do
    context 'before_destroy' do
      it 'should call #delete_file' do
        task = FactoryGirl.create(:mdm_task)
        task.should_receive(:delete_file)
        task.destroy
      end
    end
  end


end