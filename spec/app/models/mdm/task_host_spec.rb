require 'spec_helper'

describe Mdm::TaskHost do
  context "Associations" do
    it { should belong_to(:task).class_name('Mdm::Task') }
    it { should belong_to(:host).class_name('Mdm::Host') }
  end

  context "validations" do
    it "should not allow duplicate associations" do
      task = FactoryGirl.build(:mdm_task)
      host = FactoryGirl.build(:mdm_host)
      FactoryGirl.create(:mdm_task_host, :task => task, :host => host)
      task_host2 = FactoryGirl.build(:mdm_task_host, :task => task, :host => host)
      task_host2.should_not be_valid
    end
  end
end
