RSpec.describe Mdm::Listener, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'associations' do
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
    it { should belong_to(:task).class_name('Mdm::Task') }
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
    end

    context 'columns' do
      it { should have_db_column(:workspace_id).of_type(:integer).with_options(:null => false, :default =>1) }
      it { should have_db_column(:task_id).of_type(:integer) }
      it { should have_db_column(:enabled).of_type(:boolean).with_options(:default => true) }
      it { should have_db_column(:owner).of_type(:text) }
      it { should have_db_column(:payload).of_type(:text) }
      it { should have_db_column(:address).of_type(:text) }
      it { should have_db_column(:port).of_type(:integer) }
      it { should have_db_column(:options).of_type(:binary) }
      it { should have_db_column(:macro).of_type(:text) }
    end
  end

  context 'factory' do
    it 'should be valid' do
      listener = FactoryGirl.build(:mdm_listener)
      listener.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      listener = FactoryGirl.create(:mdm_listener)
      expect {
        listener.destroy
      }.to_not raise_error
      expect {
        listener.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'validations' do
    context 'port' do
      it 'should require a port' do
        portless_listener = FactoryGirl.build(:mdm_listener, :port => nil)
        portless_listener.should_not be_valid
        portless_listener.errors[:port].should include("can't be blank")
      end

      it 'should not be valid for out-of-range numbers' do
        out_of_range = FactoryGirl.build(:mdm_listener, :port => 70000)
        out_of_range.should_not be_valid
        out_of_range.errors[:port].should include("is not included in the list")
      end

      it 'should not be valid for port 0' do
        out_of_range = FactoryGirl.build(:mdm_listener, :port => 0)
        out_of_range.should_not be_valid
        out_of_range.errors[:port].should include("is not included in the list")
      end

      it 'should not be valid for decimal numbers' do
        out_of_range = FactoryGirl.build(:mdm_listener, :port => 5.67)
        out_of_range.should_not be_valid
        out_of_range.errors[:port].should include("must be an integer")
      end

      it 'should not be valid for a negative number' do
        out_of_range = FactoryGirl.build(:mdm_listener, :port => -8)
        out_of_range.should_not be_valid
        out_of_range.errors[:port].should include("is not included in the list")
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