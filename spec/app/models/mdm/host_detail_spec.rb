require 'spec_helper'

describe Mdm::HostDetail do

  context 'associations' do
    it { should belong_to(:host).class_name('Mdm::Host') }
  end

  context 'validations' do
    it 'should only be valid with a host_id' do
      orphan_detail = FactoryGirl.build(:mdm_host_detail, :host => nil)
      orphan_detail.should_not be_valid
      orphan_detail.errors[:host_id].should include("can't be blank")
    end
  end
end