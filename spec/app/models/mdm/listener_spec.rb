require 'spec_helper'

describe Mdm::Listener do

  context 'associations' do
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
    it { should belong_to(:task).class_name('Mdm::Task') }
  end

  context 'validations' do
    context 'port' do
      it 'should require a port' do
        portless_listener = FactoryGirl.build(:mdm_listener, :port => nil)
        portless_listener.should_not be_valid
        portless_listener.errors[:port].should include("can't be blank")
      end
    end

    context 'address' do
      it 'should require an address' do
        addressless_listener = FactoryGirl.build(:mdm_listener, :address => nil)
        addressless_listener.should_not be_valid
        addressless_listener.errors[:address].should include("can't be blank")
      end

      it 'should be valid for IPv4 format' do
        ipv4_listener = FactoryGirl.build(:mdm_listener, :address => '192.168.1.120')
        ipv4_listener.should be_valid
      end

      it 'should be valid for IPv6 format' do
        ipv6_listener = FactoryGirl.build(:mdm_listener, :address => '2001:0db8:85a3:0000:0000:8a2e:0370:7334')
        ipv6_listener.should be_valid
      end

      it 'should not be valid for strings not conforming to IPv4 or IPv6' do
        invalid_listener = FactoryGirl.build(:mdm_listener, :address => '1234-fark')
        invalid_listener.should_not be_valid
      end

    end
  end


end