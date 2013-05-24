require 'spec_helper'

describe Mdm::TaskCred do

  context "Associations" do
    it { should belong_to(:task).class_name('Mdm::Task') }
    it { should belong_to(:cred).class_name('Mdm::Cred') }
  end

  context "validations" do
    it "should not allow duplicate associations" do
      task = FactoryGirl.build(:mdm_task)
      cred = FactoryGirl.build(:mdm_cred)
      FactoryGirl.create(:mdm_task_cred, :task => task, :cred => cred)
      task_cred2 = FactoryGirl.build(:mdm_task_cred, :task => task, :cred => cred)
      task_cred2.should_not be_valid
    end
  end

end
