require 'spec_helper'

describe Mdm::TaskService do
  context "Associations" do
    it { should belong_to(:task).class_name('Mdm::Task') }
    it { should belong_to(:service).class_name('Mdm::Service') }
  end
end
