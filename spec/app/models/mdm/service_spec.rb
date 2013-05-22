require 'spec_helper'

describe Mdm::Service do

  context "Associations" do

    it { should have_many(:task_services).class_name('Mdm::TaskService') }
    it { should have_many(:tasks).class_name('Mdm::Task').through(:task_services) }

    it { should belong_to(:host).class_name('Mdm::Host') }
  end

end