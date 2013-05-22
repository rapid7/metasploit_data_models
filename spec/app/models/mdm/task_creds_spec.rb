require 'spec_helper'

describe Mdm::TaskCred do

  context "Associations" do
    it { should belong_to(:task).class_name('Mdm::Task') }
    it { should belong_to(:cred).class_name('Mdm::Cred') }
  end

end
