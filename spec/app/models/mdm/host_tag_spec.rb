require 'spec_helper'

describe Mdm::HostTag do

  context 'associations' do
    it { should belong_to(:host).class_name('Mdm::Host') }
    it { should belong_to(:tag).class_name('Mdm::Tag') }
  end

  context 'factories' do
    context 'mdm_host_tag' do
      subject(:mdm_host_tag) do
        FactoryGirl.build(:mdm_host_tag)
      end

      it { should be_valid }
    end
  end
end