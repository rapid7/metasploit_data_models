describe Mdm::NexposeConsole, type: :model do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'factory' do
    it 'should be valid' do
      nexpose_console = FactoryGirl.build(:mdm_nexpose_console)
      nexpose_console.should be_valid
    end
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime).with_options(:null => false) }
      it { should have_db_column(:updated_at).of_type(:datetime).with_options(:null => false) }
    end

    context 'columns' do
      it { should have_db_column(:enabled).of_type(:boolean).with_options(:default => true) }
      it { should have_db_column(:owner).of_type(:text) }
      it { should have_db_column(:address).of_type(:text) }
      it { should have_db_column(:port).of_type(:integer).with_options(:default => 3780) }
      it { should have_db_column(:username).of_type(:text) }
      it { should have_db_column(:password).of_type(:text) }
      it { should have_db_column(:status).of_type(:text) }
      it { should have_db_column(:version).of_type(:text) }
      it { should have_db_column(:cert).of_type(:text) }
      it { should have_db_column(:cached_sites).of_type(:binary) }
      it { should have_db_column(:name).of_type(:text) }
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      nexpose_console = FactoryGirl.create(:mdm_nexpose_console)
      expect {
        nexpose_console.destroy
      }.to_not raise_error
      expect {
        nexpose_console.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
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

  context 'callbacks' do
    describe '#strip_protocol' do
      it 'should strip protocol handlers from the front of the address' do
        nexpose_console = FactoryGirl.create(:mdm_nexpose_console, :address => 'https://foo.bar.com')
        expect(nexpose_console.address).to eq 'foo.bar.com'
      end

    end
  end

end