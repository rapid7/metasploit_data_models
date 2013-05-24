require 'spec_helper'

describe Mdm::Task do

  context "Associations" do

    it { should have_many(:task_creds).class_name('Mdm::TaskCred').dependent(:destroy) }
    it { should have_many(:creds).class_name('Mdm::Cred').through(:task_creds) }
    it { should have_many(:task_hosts).class_name('Mdm::TaskHost').dependent(:destroy) }
    it { should have_many(:hosts).class_name('Mdm::Host').through(:task_hosts) }
    it { should have_many(:task_services).class_name('Mdm::TaskService').dependent(:destroy) }
    it { should have_many(:services).class_name('Mdm::Service').through(:task_services) }
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
  end

  context "running" do
    it "should exclude completed tasks" do
      task = FactoryGirl.create(:mdm_task, :completed_at => Time.now)
      Mdm::Task.running.should_not include(task)
    end

  end

end