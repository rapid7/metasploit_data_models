require 'spec_helper'

describe Mdm::Cred do

  context "Associations" do
    it { should have_many(:task_creds).class_name('Mdm::TaskCred').dependent(:destroy) }
    it { should have_many(:tasks).class_name('Mdm::Task').through(:task_creds) }
    it { should belong_to(:service).class_name('Mdm::Service') }
  end

  context '#destroy' do
    it 'should successfully destroy the object and all dependent objects' do
      cred = FactoryGirl.create(:mdm_cred)
      task_cred = FactoryGirl.create(:mdm_task_cred, :cred => cred)
      expect {
        cred.destroy
      }.to_not raise_error
      expect {
        cred.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect {
        task_cred.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'callbacks' do
    context 'after_create' do
      it 'should increment cred_count on the host' do
        host = FactoryGirl.create(:mdm_host)
        svc = FactoryGirl.create(:mdm_service, :host => host)
        expect {
          FactoryGirl.create(:mdm_cred, :service => svc)
        }.to change{ Mdm::Host.find(host.id).cred_count}.by(1)
      end
    end

    context 'after_destroy' do
      it 'should decrement cred_count on the host' do
        host = FactoryGirl.create(:mdm_host)
        svc = FactoryGirl.create(:mdm_service, :host => host)
        cred =FactoryGirl.create(:mdm_cred, :service => svc)
        expect {
          cred.destroy
        }.to change{ Mdm::Host.find(host.id).cred_count}.by(-1)
      end
    end
  end

  context 'constants' do
    it 'should define the key_id regex' do
      described_class::KEY_ID_REGEX.should == /([0-9a-fA-F:]{47})/
    end

    it 'should define ptypes to humanize' do
      described_class::PTYPES.should == {
          'read/write password' => 'password_rw',
          'read-only password' => 'password_ro',
          'SMB hash' => 'smb_hash',
          'SSH private key' => 'ssh_key',
          'SSH public key' => 'ssh_pubkey'
      }
    end
  end

  context 'methods' do
    before(:all) do
      Mdm::Workspace.any_instance.stub(:valid_ip_or_range? => true)
      workspace =  FactoryGirl.create(:mdm_workspace)
      host = FactoryGirl.create(:mdm_host, :workspace => workspace)
      @svc1 = FactoryGirl.create(:mdm_service, :host => host)
      @svc2 = FactoryGirl.create(:mdm_service, :host => host)
      @cred1 = FactoryGirl.create(:mdm_cred, :service => @svc1, :user => 'msfadmin', :pass => '/path/to/keyfile', :ptype => 'ssh_key', :proof => "KEY=57:c3:11:5d:77:c5:63:90:33:2d:c5:c4:99:78:62:7a")
      @pubkey = FactoryGirl.create(:mdm_cred, :service => @svc1, :user => 'msfadmin', :pass => '/path/to/keyfile', :ptype => 'ssh_pubkey', :proof => "KEY=57:c3:11:5d:77:c5:63:90:33:2d:c5:c4:99:78:62:7a")
    end

    context '#ptype_human' do
      it "should return 'read/write password' for 'password_rw'" do
        cred = FactoryGirl.build(:mdm_cred, :user => 'msfadmin', :pass => 'msfadmin', :ptype => 'password_rw')
        cred.ptype_human.should == 'read/write password'
      end

      it "should return 'read-only password' for 'password_ro'" do
        cred = FactoryGirl.build(:mdm_cred, :user => 'msfadmin', :pass => 'msfadmin', :ptype => 'password_ro')
        cred.ptype_human.should == 'read-only password'
      end

      it "should return 'SMB Hash' for 'smb_hash'" do
        cred = FactoryGirl.build(:mdm_cred, :user => 'msfadmin', :pass => 'msfadmin', :ptype => 'smb_hash')
        cred.ptype_human.should == 'SMB hash'
      end

      it "should return 'SSH private key' for 'ssh_key'" do
        cred = FactoryGirl.build(:mdm_cred, :user => 'msfadmin', :pass => 'msfadmin', :ptype => 'ssh_key')
        cred.ptype_human.should == 'SSH private key'
      end

      it "should return 'SSH public key' for 'ssh_pubkey'" do
        cred = FactoryGirl.build(:mdm_cred, :user => 'msfadmin', :pass => 'msfadmin', :ptype => 'ssh_pubkey')
        cred.ptype_human.should == 'SSH public key'
      end
    end

    context '#ssh_key_id' do
      it 'should return nil if not an ssh_key' do
        cred = FactoryGirl.build(:mdm_cred, :user => 'msfadmin', :pass => 'msfadmin', :ptype => 'password_rw')
        cred.ssh_key_id.should == nil
      end

      it 'should return nil if proof does not contain the key id' do
        cred = FactoryGirl.build(:mdm_cred, :user => 'msfadmin', :pass => '/path/to/keyfile', :ptype => 'ssh_key', :proof => "no key here")
        cred.ssh_key_id.should == nil
      end

      it 'should return the key id for an ssh_key' do
        cred = FactoryGirl.build(:mdm_cred, :user => 'msfadmin', :pass => '/path/to/keyfile', :ptype => 'ssh_key', :proof => "KEY=57:c3:11:5d:77:c5:63:90:33:2d:c5:c4:99:78:62:7a")
        cred.ssh_key_id.should == '57:c3:11:5d:77:c5:63:90:33:2d:c5:c4:99:78:62:7a'
      end

    end

    context '#ssh_key_matches?' do
      it 'should return true if the ssh_keys match' do
        cred2 = FactoryGirl.create(:mdm_cred, :service => @svc2, :user => 'msfadmin', :pass => '/path/to/keyfile', :ptype => 'ssh_key', :proof => "KEY=57:c3:11:5d:77:c5:63:90:33:2d:c5:c4:99:78:62:7a")
        cred2.ssh_key_matches?(@cred1).should == true
      end

      it 'should return false if passed something other than a cred' do
        @cred1.ssh_key_matches?(@svc1).should == false
      end

      it 'should return false if the ptypes do not match' do
        cred2 = FactoryGirl.create(:mdm_cred, :service => @svc2, :user => 'msfadmin', :pass => '/path/to/keyfile', :ptype => 'ssh_pubkey', :proof => "KEY=57:c3:11:5d:77:c5:63:90:33:2d:c5:c4:99:78:62:7a")
        cred2.ssh_key_matches?(@cred1).should == false
      end

      it 'should return false if the key ids do not match' do
        cred2 = FactoryGirl.create(:mdm_cred, :service => @svc2, :user => 'msfadmin', :pass => '/path/to/keyfile', :ptype => 'ssh_pubkey', :proof => "KEY=66:d4:22:6e:88:d6:74:A1:44:3e:d6:d5:AA:89:73:8b")
        cred2.ssh_key_matches?(@cred1).should == false
      end

      it 'should behave the same for public keys as private keys' do
        pubkey2 = FactoryGirl.create(:mdm_cred, :service => @svc1, :user => 'msfadmin', :pass => '/path/to/keyfile', :ptype => 'ssh_pubkey', :proof => "KEY=57:c3:11:5d:77:c5:63:90:33:2d:c5:c4:99:78:62:7a")
        pubkey3 = FactoryGirl.create(:mdm_cred, :service => @svc1, :user => 'msfadmin', :pass => '/path/to/keyfile', :ptype => 'ssh_pubkey', :proof => "KEY=66:d4:22:6e:88:d6:74:A1:44:3e:d6:d5:AA:89:73:8b")
        pubkey2.ssh_key_matches?(@pubkey).should == true
        pubkey2.ssh_key_matches?(pubkey3).should == false
      end

      it 'should always return false for non ssh key creds' do
        cred2 = FactoryGirl.create(:mdm_cred, :service => @svc2, :ptype => 'password', :user => 'msfadmin', :pass => 'msfadmin' )
        cred3 = FactoryGirl.create(:mdm_cred, :service => @svc2, :ptype => 'password', :user => 'msfadmin', :pass => 'msfadmin' )
        cred2.ssh_key_matches?(cred3).should == false
      end
    end

    context '#ssh_keys' do
      before(:all) do
        @cred2 = FactoryGirl.create(:mdm_cred, :service => @svc2, :user => 'msfadmin', :pass => '/path/to/keyfile', :ptype => 'ssh_key', :proof => "KEY=57:c3:11:5d:77:c5:63:90:33:2d:c5:c4:99:78:62:7a")
      end
      it 'should return all ssh private keys with a matching id' do
        @cred2.ssh_keys.should include(@cred1)
      end

      it 'should return all ssh public keys with a matching id' do
        @cred2.ssh_keys.should include(@pubkey)
      end
    end

    context '#ssh_private_keys' do
      before(:all) do
        @cred2 = FactoryGirl.create(:mdm_cred, :service => @svc2, :user => 'msfadmin', :pass => '/path/to/keyfile', :ptype => 'ssh_key', :proof => "KEY=57:c3:11:5d:77:c5:63:90:33:2d:c5:c4:99:78:62:7a")
      end

      it 'should return ssh private keys with matching ids' do
        @cred2.ssh_private_keys.should include(@cred1)
      end

      it 'should not return ssh public keys with matching ids' do
        @cred2.ssh_private_keys.should_not include(@pubkey)
      end
    end

    context '#ssh_public_keys' do
      before(:all) do
        @cred2 = FactoryGirl.create(:mdm_cred, :service => @svc2, :user => 'msfadmin', :pass => '/path/to/keyfile', :ptype => 'ssh_key', :proof => "KEY=57:c3:11:5d:77:c5:63:90:33:2d:c5:c4:99:78:62:7a")
      end

      it 'should not return ssh private keys with matching ids' do
        @cred2.ssh_public_keys.should_not include(@cred1)
      end

      it 'should return ssh public keys with matching ids' do
        @cred2.ssh_public_keys.should include(@pubkey)
      end
    end

  end

  context 'factory' do
    it 'should be valid' do
      cred = FactoryGirl.build(:mdm_cred)
      cred.should be_valid
    end
  end

end