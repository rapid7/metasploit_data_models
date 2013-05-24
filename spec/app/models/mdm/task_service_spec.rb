require 'spec_helper'

describe Mdm::TaskService do
  context "Associations" do
    it { should belong_to(:task).class_name('Mdm::Task') }
    it { should belong_to(:service).class_name('Mdm::Service') }
  end

  context "validations" do
    it "should not allow duplicate associations" do
      task = FactoryGirl.build(:mdm_task)
      service = FactoryGirl.build(:mdm_service)
      FactoryGirl.create(:mdm_task_service, :task => task, :service => service)
      task_service2 = FactoryGirl.build(:mdm_task_service, :task => task, :service => service)
      task_service2.should_not be_valid
    end
  end
end
