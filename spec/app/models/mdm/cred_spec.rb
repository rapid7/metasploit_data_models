require 'spec_helper'

describe Mdm::Cred do

  context "Associations" do
    it { should have_many(:task_creds).class_name('Mdm::TaskCred') }
    it { should have_many(:tasks).class_name('Mdm::Task').through(:task_creds) }
    it { should belong_to(:service).class_name('Mdm::Service') }
  end



end