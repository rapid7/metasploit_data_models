require 'spec_helper'

describe Mdm::TaskService do

  context 'factory' do
    it 'should be valid' do
      task_service = FactoryGirl.build(:mdm_task_service)
      task_service.should be_valid
    end
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
    end

    context 'columns' do
      it { should have_db_column(:task_id).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:service_id).of_type(:integer).with_options(:null => false) }
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      task_service = FactoryGirl.create(:mdm_task_service)
      expect {
        task_service.destroy
      }.to_not raise_error
      expect {
        task_service.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

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
