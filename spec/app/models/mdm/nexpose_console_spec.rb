require 'spec_helper'

describe Mdm::NexposeConsole do

  context 'factory' do
    it 'should be valid' do
      nexpose_console = FactoryGirl.build(:mdm_nexpose_console)
      nexpose_console.should be_valid
    end
  end

  context 'validations' do
    context 'address' do
      it 'should require an address' do
        addressless_nexpose_console = FactoryGirl.build(:mdm_nexpose_console, :address => nil)
        addressless_nexpose_console.should_not be_valid
        addressless_nexpose_console.errors[:address].should include("can't be blank")
      end

      it 'should be valid for IPv4 format' do
        ipv4_nexpose_console = FactoryGirl.build(:mdm_nexpose_console, :address => '192.168.1.120')
        ipv4_nexpose_console.should be_valid
      end

      it 'should be valid for IPv6 format' do
        ipv6_nexpose_console = FactoryGirl.build(:mdm_nexpose_console, :address => '2001:0db8:85a3:0000:0000:8a2e:0370:7334')
        ipv6_nexpose_console.should be_valid
      end

      it 'should not be valid for strings not conforming to IPv4 or IPv6' do
        invalid_nexpose_console = FactoryGirl.build(:mdm_nexpose_console, :address => '1234-fark')
        invalid_nexpose_console.should_not be_valid
      end
    end

    context 'port' do
      it 'should require a port' do
        portless_nexpose_console = FactoryGirl.build(:mdm_nexpose_console, :port => nil)
        portless_nexpose_console.should_not be_valid
        portless_nexpose_console.errors[:port].should include("is not included in the list")
      end

      it 'should not be valid for out-of-range numbers' do
        out_of_range = FactoryGirl.build(:mdm_nexpose_console, :port => 70000)
        out_of_range.should_not be_valid
        out_of_range.errors[:port].should include("is not included in the list")
      end

      it 'should not be valid for port 0' do
        out_of_range = FactoryGirl.build(:mdm_nexpose_console, :port => 0)
        out_of_range.should_not be_valid
        out_of_range.errors[:port].should include("is not included in the list")
      end

      it 'should not be valid for decimal numbers' do
        out_of_range = FactoryGirl.build(:mdm_nexpose_console, :port => 5.67)
        out_of_range.should_not be_valid
        out_of_range.errors[:port].should include("must be an integer")
      end

      it 'should not be valid for a negative number' do
        out_of_range = FactoryGirl.build(:mdm_nexpose_console, :port => -8)
        out_of_range.should_not be_valid
        out_of_range.errors[:port].should include("is not included in the list")
      end
    end

    context 'name' do
      it 'should require a name' do
        unnamed_console = FactoryGirl.build(:mdm_nexpose_console, :name => nil)
        unnamed_console.should_not be_valid
        unnamed_console.errors[:name].should include("can't be blank")
      end
    end

    context 'username' do
      it 'should require a name' do
        console = FactoryGirl.build(:mdm_nexpose_console, :username => nil)
        console.should_not be_valid
        console.errors[:username].should include("can't be blank")
      end
    end

    context 'password' do
      it 'should require a password' do
        console = FactoryGirl.build(:mdm_nexpose_console, :password => nil)
        console.should_not be_valid
        console.errors[:password].should include("can't be blank")
      end
    end

  end

end