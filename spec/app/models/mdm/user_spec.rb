require 'spec_helper'

describe Mdm::User do

  context 'associations' do
    it { should have_many(:owned_workspaces).class_name('Mdm::Workspace') }
    it { should have_many(:tags).class_name('Mdm::Tag') }
    it { should have_and_belong_to_many(:workspaces).class_name('Mdm::Workspace') }
  end
end