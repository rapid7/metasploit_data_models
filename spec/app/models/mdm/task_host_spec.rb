require 'spec_helper'

describe Mdm::TaskHost do
  context "Associations" do
    it { should belong_to(:task).class_name('Mdm::Task') }
    it { should belong_to(:host).class_name('Mdm::Host') }
  end
end
