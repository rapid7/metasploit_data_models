require 'spec_helper'

describe Mdm::Host do
  subject(:host) do
    FactoryGirl.build(:mdm_host)
  end

  let(:architectures) do
    [
        'armbe',
        'armle',
        'cbea',
        'cbea64',
        'cmd',
        'java',
        'mips',
        'mipsbe',
        'mipsle',
        'php',
        'ppc',
        'ppc64',
        'ruby',
        'sparc',
        'tty',
        'x64',
        'x86',
        'x86_64',
        '',
        'Unknown',
    ]
  end

  let(:states) do
    [
        'alive',
        'down',
        'unknown'
    ]
  end

  it_should_behave_like 'Metasploit::Concern.run'

  context 'factory' do
    it 'should be valid' do
      host = FactoryGirl.build(:mdm_host)
      host.should be_valid
    end
  end

  context 'Constants' do
    subject(:max_nmap_certainty) { described_class::MAX_NMAP_CERTAINTY }
    it { should eq(0.84) }
  end

  context '#destroy' do
    it 'should successfully destroy the object and the dependent objects' do
      host = FactoryGirl.create(:mdm_host)
      exploit_attempt = FactoryGirl.create(:mdm_exploit_attempt, :host => host)
      exploited_host = FactoryGirl.create(:mdm_exploited_host, :host => host)
      host_detail = FactoryGirl.create(:mdm_host_detail, :host => host)
      loot = FactoryGirl.create(:mdm_loot, :host => host)
      task_host = FactoryGirl.create(:mdm_task_host, :host => host)
      note = FactoryGirl.create(:mdm_note, :host => host)
      svc = FactoryGirl.create(:mdm_service, :host => host)
      session = FactoryGirl.create(:mdm_session, :host => host)
      vuln = FactoryGirl.create(:mdm_vuln, :host => host)


      expect {
        host.destroy
      }.to_not raise_error
      expect {
        host.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect {
        exploit_attempt.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect {
        exploited_host.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect {
        host_detail.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect {
        loot.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect {
        task_host.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect {
        note.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect {
        svc.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect {
        session.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
      expect {
        vuln.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'associations' do
    it { should have_many(:creds).class_name('Mdm::Cred').through(:services) }
    it { should have_many(:clients).class_name('Mdm::Client').dependent(:destroy) }
    it { should have_many(:exploit_attempts).class_name('Mdm::ExploitAttempt').dependent(:destroy) }
    it { should have_many(:exploited_hosts).class_name('Mdm::ExploitedHost').dependent(:destroy) }
    it { should have_many(:host_details).class_name('Mdm::HostDetail').dependent(:destroy) }
    it { should have_many(:hosts_tags).class_name('Mdm::HostTag') }
    it { should have_many(:loots).class_name('Mdm::Loot').dependent(:destroy).order('loots.created_at DESC') }
    it { should have_many(:module_runs).class_name('MetasploitDataModels::ModuleRun') }
    it { should have_many(:task_hosts).class_name('Mdm::TaskHost').dependent(:destroy) }
    it { should have_many(:tasks).class_name('Mdm::Task').through(:task_hosts) }

    context 'module_details' do
      it { should have_many(:module_details).class_name('Mdm::Module::Detail').through(:module_refs) }

      context 'with Mdm::Vulns' do
        let!(:vulns) do
          FactoryGirl.create_list(
              :mdm_vuln,
              2,
              :host => host
          )
        end

        context 'with Mdm::Ref' do
          let(:name) do
            FactoryGirl.generate :mdm_ref_name
          end

          let!(:ref) do
            FactoryGirl.create(:mdm_ref, :name => name)
          end

          context 'with Mdm::VulnRefs' do
            let!(:vuln_refs) do
              vulns.collect { |vuln|
                FactoryGirl.create(:mdm_vuln_ref, :ref => ref, :vuln => vuln)
              }
            end

            context 'with Mdm::Module::Detail' do
              let!(:module_detail) do
                FactoryGirl.create(
                    :mdm_module_detail
                )
              end

              context 'with Mdm::Module::Ref with same name as Mdm::Ref' do
                let!(:module_ref) do
                  FactoryGirl.create(
                      :mdm_module_ref,
                      :detail => module_detail,
                      :name => name
                  )
                end

                it 'should list unique Mdm::Module::Detail' do
                  expect(host.module_details).to match_array([module_detail])
                end

                it 'should have duplicate Mdm::Module::Details if collected through chain' do
                  vuln_refs = []

                  host.vulns.each do |vuln|
                    # @todo https://www.pivotaltracker.com/story/show/49004623
                    vuln_refs += vuln.vulns_refs
                  end

                  refs = []

                  vuln_refs.each do |vuln_ref|
                    refs << vuln_ref.ref
                  end

                  module_refs = []

                  refs.each do |ref|
                    module_refs += ref.module_refs
                  end

                  module_details = []

                  module_refs.each do |module_ref|
                    module_details << module_ref.detail
                  end

                  host.module_details.count.should < module_details.length
                  module_details.uniq.count.should == host.module_details.count
                end
              end
            end
          end
        end
      end
    end

    it { should have_many(:module_refs).class_name('Mdm::Module::Ref').through(:refs) }
    it { should have_many(:notes).class_name('Mdm::Note').dependent(:delete_all).order('notes.created_at') }
    it { should have_many(:refs).class_name('Mdm::Ref').through(:vuln_refs) }
    it { should have_many(:services).class_name('Mdm::Service').dependent(:destroy).order('services.port, services.proto') }
    it { should have_many(:service_notes).through(:services) }
    it { should have_many(:sessions).class_name('Mdm::Session').dependent(:destroy).order('sessions.opened_at') }
    it { should have_many(:tags).class_name('Mdm::Tag').through(:hosts_tags) }
    it { should have_many(:vulns).class_name('Mdm::Vuln').dependent(:delete_all) }
    it { should have_many(:vuln_refs).class_name('Mdm::VulnRef') }
    it { should have_many(:web_sites).class_name('Mdm::WebSite').through(:services) }
    it { should belong_to(:workspace).class_name('Mdm::Workspace') }
  end

  context 'CONSTANTS' do
    context 'ARCHITECTURES' do
      subject(:architectures) do
        described_class::ARCHITECTURES
      end

      it 'should be an Array<String>' do
        architectures.should be_an Array

        architectures.each do |architecture|
          architecture.should be_a String
        end
      end

      it 'should include both endians of ARM' do
        architectures.should include('armbe')
        architectures.should include('armle')
      end

      it 'should include 32-bit and 64-bit versions of Cell Broadband Engine Architecture' do
        architectures.should include('cbea')
        architectures.should include('cbea64')
      end

      it 'should include cmd for command shell' do
        architectures.should include('cmd')
      end

      it 'should include java for Java Virtual Machine' do
        architectures.should include('java')
      end

      it 'should include plain and endian-ware MIPS' do
        architectures.should include('mips')
        architectures.should include('mipsbe')
        architectures.should include('mipsle')
      end

      it 'should include php for PHP code' do
        architectures.should include('php')
      end

      it 'should include 32-bit and 64-bit PowerPC' do
        architectures.should include('ppc')
        architectures.should include('ppc64')
      end

      it 'should include ruby for Ruby code' do
        architectures.should include('ruby')
      end

      it 'should include sparc for Sparc' do
        architectures.should include('sparc')
      end

      it 'should include tty for Terminals' do
        architectures.should include('tty')
      end

      it 'should include 32-bit and 64-bit x86' do
        architectures.should include('x64')
        architectures.should include('x86')
        architectures.should include('x86_64')
      end

      it 'should include blank string to indicate no detection has happened' do
        architectures.should include('')
      end

      it 'should include "Unknown" for failed detection attempts' do
        architectures.should include('Unknown')
      end

    end

    context 'SEARCH_FIELDS' do
      subject(:search_fields) do
        described_class::SEARCH_FIELDS
      end

      it 'should be an Array<String>' do
        search_fields.should be_an Array

        search_fields.each { |search_field|
          search_field.should be_a String
        }
      end

      it 'should cast address to text' do
        search_fields.should include('address::text')
      end

      it { should include('comments') }
      it { should include('mac') }
      it { should include('name') }
      it { should include('os_flavor') }
      it { should include('os_name') }
      it { should include('os_sp') }
      it { should include('purpose') }
    end

    it 'should define STATES in any order' do
      described_class::STATES.should =~ states
    end
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:address).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:arch).of_type(:string) }
      it { should have_db_column(:comm).of_type(:string) }
      it { should have_db_column(:comments).of_type(:text) }
      it { should have_db_column(:info).of_type(:string).with_options(:limit => 2 ** 16) }
      it { should have_db_column(:mac).of_type(:string) }
      it { should have_db_column(:name).of_type(:string) }
      it { should have_db_column(:os_flavor).of_type(:string) }
      it { should have_db_column(:os_lang).of_type(:string) }
      it { should have_db_column(:os_name).of_type(:string) }
      it { should have_db_column(:os_sp).of_type(:string) }
      it { should have_db_column(:purpose).of_type(:text) }
      it { should have_db_column(:scope).of_type(:text) }
      it { should have_db_column(:state).of_type(:string) }
      it { should have_db_column(:virtual_host).of_type(:text) }
      it { should have_db_column(:workspace_id).of_type(:integer).with_options(:null => false) }

      context 'counter caches' do
        it { should have_db_column(:exploit_attempt_count).of_type(:integer).with_options(:default => 0) }
        it { should have_db_column(:host_detail_count).of_type(:integer).with_options(:default => 0) }
        it { should have_db_column(:note_count).of_type(:integer).with_options(:default => 0) }
        it { should have_db_column(:service_count).of_type(:integer).with_options(:default => 0) }
        it { should have_db_column(:vuln_count).of_type(:integer).with_options(:default => 0) }
      end

      context 'timestamps' do
        it { should have_db_column(:created_at).of_type(:datetime) }
        it { should have_db_column(:updated_at).of_type(:datetime) }
      end
    end

    context 'indices' do
      it { should have_db_index([:workspace_id, :address]).unique(true) }
      it { should have_db_index(:name) }
      it { should have_db_index(:os_flavor) }
      it { should have_db_index(:os_name) }
      it { should have_db_index(:purpose) }
      it { should have_db_index(:state) }
    end
  end

  context 'factories' do
    context 'full_mdm_host' do
      subject(:full_mdm_host) do
        FactoryGirl.build(:full_mdm_host)
      end

      it { should be_valid }
    end

    context 'mdm_host' do
      subject(:mdm_host) do
        FactoryGirl.build(:mdm_host)
      end

      it { should be_valid }
    end
  end

  context 'validations' do
    context 'address' do
      it { should validate_exclusion_of(:address).in_array(['127.0.0.1']) }
      it { should validate_presence_of(:address) }

      # can't use validate_uniqueness_of(:address).scoped_to(:workspace_id) because it will attempt to set workspace_id
      # to `nil`, which will make the `:null => false` constraint on hosts.workspace_id to fail.
      it 'should validate uniqueness of address scoped to workspace_id' do
        address = '192.168.0.1'

        workspace = FactoryGirl.create(:mdm_workspace)
        FactoryGirl.create(:mdm_host, :address => address, :workspace => workspace)

        duplicate_host = FactoryGirl.build(:mdm_host, :address => address, :workspace => workspace)

        duplicate_host.should_not be_valid
        duplicate_host.errors[:address].should include('has already been taken')
      end
    end

    context 'arch' do
      let(:workspace) { FactoryGirl.create(:mdm_workspace) }
      let(:address) { '192.168.0.1' }
      let(:host) { FactoryGirl.create(:mdm_host, :address => address, :workspace => workspace, :arch => arch) }
      context 'with an unknown architecture' do
        let(:arch) { "asdfasdf" }
        it 'should normalize to Unknown' do
          host.should be_valid
          host.arch.should be described_class::UNKNOWN_ARCHITECTURE
        end
      end
      described_class::ARCHITECTURES.each do |arch|
        context "with known architecture '#{arch}'" do
          let(:arch) { arch }
          it { should be_valid }
        end
      end
    end
    it { should validate_inclusion_of(:state).in_array(states).allow_nil }
    it { should validate_presence_of(:workspace) }
  end

  context 'search scope' do
    subject(:full_mdm_host) do
      FactoryGirl.create(:full_mdm_host)
    end

    def search_for(str)
      Mdm::Host.search(str)
    end

    context 'searching for an empty string' do
      it 'should return any hosts in the database' do
        search_for('').should include(subject)
      end
    end

    context 'searching for an existing Host\'s name' do
      it 'should return the host' do
        search_for(subject.name).should include(subject)
      end
    end
  end

  context 'os normalization' do
    context '#get_arch_from_string' do
      context "should return 'x64'" do
        it "when the string contains 'x64'" do
          host.send(:get_arch_from_string, 'blahx64blah').should == 'x64'
        end

        it "when the string contains 'X64'" do
          host.send(:get_arch_from_string, 'blahX64blah').should == 'x64'
        end

        it "when the string contains 'x86_64'" do
          host.send(:get_arch_from_string, 'blahx86_64blah').should == 'x64'
        end

        it "when the string contains 'X86_64'" do
          host.send(:get_arch_from_string, 'blahX86_64blah').should == 'x64'
        end

        it "when the string contains 'amd64'" do
          host.send(:get_arch_from_string, 'blahamd64blah').should == 'x64'
        end

        it "when the string contains 'AMD64'" do
          host.send(:get_arch_from_string, 'blahAMD64blah').should == 'x64'
        end

        it "when the string contains 'aMd64'" do
          host.send(:get_arch_from_string, 'blahamd64blah').should == 'x64'
        end
      end

      context "should return 'x86'" do
        it "when the string contains 'x86'" do
          host.send(:get_arch_from_string, 'blahx86blah').should == 'x86'
        end

        it "when the string contains 'X86'" do
          host.send(:get_arch_from_string, 'blahX86blah').should == 'x86'
        end

        it "when the string contains 'i386'" do
          host.send(:get_arch_from_string, 'blahi386blah').should == 'x86'
        end

        it "when the string contains 'I386'" do
          host.send(:get_arch_from_string, 'blahI386blah').should == 'x86'
        end

        it "when the string contains 'i486'" do
          host.send(:get_arch_from_string, 'blahi486blah').should == 'x86'
        end

        it "when the string contains 'i586'" do
          host.send(:get_arch_from_string, 'blahi586blah').should == 'x86'
        end

        it "when the string contains 'i686'" do
          host.send(:get_arch_from_string, 'blahi386blah').should == 'x86'
        end
      end

      context "should return 'ppc'" do
        it "when the string contains 'PowerPC'" do
          host.send(:get_arch_from_string, 'blahPowerPCblah').should == 'ppc'
        end

        it "when the string contains 'PPC'" do
          host.send(:get_arch_from_string, 'blahPPCblah').should == 'ppc'
        end

        it "when the string contains 'POWER'" do
          host.send(:get_arch_from_string, 'blahPOWERblah').should == 'ppc'
        end

        it "when the string contains 'ppc'" do
          host.send(:get_arch_from_string, 'blahppcblah').should == 'ppc'
        end
      end

      context 'should return nil' do
        it 'when PowerPC is cased incorrectly' do
          host.send(:get_arch_from_string, 'powerPC').should == nil
          host.send(:get_arch_from_string, 'Powerpc').should == nil
        end

        it 'when no recognized arch string is present' do
          host.send(:get_arch_from_string, 'blahblah').should == nil
        end
      end

      it "should return 'sparc' if the string contains SPARC, regardless of case" do
        host.send(:get_arch_from_string, 'blahSPARCblah').should == 'sparc'
        host.send(:get_arch_from_string, 'blahSPaRCblah').should == 'sparc'
        host.send(:get_arch_from_string, 'blahsparcblah').should == 'sparc'
      end

      it "should return 'arm' if the string contains 'ARM', regardless of case" do
        host.send(:get_arch_from_string, 'blahARMblah').should == 'arm'
        host.send(:get_arch_from_string, 'blahArMblah').should == 'arm'
        host.send(:get_arch_from_string, 'blaharmblah').should == 'arm'
      end

      it "should return 'mips' if the string contains 'MIPS', regardless of case" do
        host.send(:get_arch_from_string, 'blahMIPSblah').should == 'mips'
        host.send(:get_arch_from_string, 'blahMiPslah').should == 'mips'
        host.send(:get_arch_from_string, 'blahmipsblah').should == 'mips'
      end
    end

    context '#parse_windows_os_str' do
      it 'should always return the os_name as Windows' do
        result = host.send(:parse_windows_os_str, '')
        result['os.product'].should == 'Windows'
      end

      context 'arch' do
        it 'should return a value for arch if there is one' do
          result = host.send(:parse_windows_os_str, 'Windows x64')
          result['os.arch'].should == 'x64'
        end

        it "should not have an arch key if we don't know the arch" do
          result = host.send(:parse_windows_os_str, 'Windows')
          result.has_key?('os.arch').should == false
        end
      end

      context 'Service Pack' do
        it 'should be returned if we see Service Pack X' do
          result = host.send(:parse_windows_os_str, 'Windows XP Service Pack 1')
          result['os.version'].should == 'SP1'
        end

        it 'should be returned if we see SPX' do
          result = host.send(:parse_windows_os_str, 'Windows XP SP3')
          result['os.version'].should == 'SP3'
        end
      end

      context 'os product' do

         it "should appear as Windows 95 for 'Windows 95" do
          result = host.send(:parse_windows_os_str, 'Windows 95')
          result['os.product'].should == 'Windows 95'
        end

        it "should appear as Windows NT 3.51 for 'Windows NT 3.51" do
          result = host.send(:parse_windows_os_str, 'Windows NT 3.51')
          result['os.product'].should == 'Windows NT 3.51'
        end

        it "should appear as Windows NT 4.0 for 'Windows NT 4.0" do
          result = host.send(:parse_windows_os_str, 'Windows NT 4.0')
          result['os.product'].should == 'Windows NT 4.0'
        end

        it "should appear as Windows 98 for 'Windows 98" do
          result = host.send(:parse_windows_os_str, 'Windows 98')
          result['os.product'].should == 'Windows 98'
        end

        it "should appear as Windows ME for 'Windows ME" do
          result = host.send(:parse_windows_os_str, 'Windows ME')
          result['os.product'].should == 'Windows ME'
        end

        it "should appear as Windows 2003 for '.NET Server'" do
          result = host.send(:parse_windows_os_str, 'Windows .NET Server')
          result['os.product'].should == 'Windows Server 2003'
        end

        it 'should be recognized for Windows XP' do
          result = host.send(:parse_windows_os_str, 'Windows XP')
          result['os.product'].should == 'Windows XP'
        end

        it 'should be recognized for Windows Server 2000' do
          result = host.send(:parse_windows_os_str, 'Windows 2000')
          result['os.product'].should == 'Windows Server 2000'
        end

        it 'should be recognized for Windows Server 2003' do
          result = host.send(:parse_windows_os_str, 'Windows 2003')
          result['os.product'].should == 'Windows Server 2003'
        end

        it 'should be recognized for Windows 2008' do
          result = host.send(:parse_windows_os_str, 'Windows 2008')
          result['os.product'].should == 'Windows Server 2008'
        end

        it 'should be recognized for Windows 2012' do
          result = host.send(:parse_windows_os_str, 'Windows 2012')
          result['os.product'].should == 'Windows Server 2012'
        end

        it 'should be recognized for Windows Vista' do
          result = host.send(:parse_windows_os_str, 'Windows Vista')
          result['os.product'].should == 'Windows Vista'
        end

        it 'should be recognized for Windows Server 2000' do
          result = host.send(:parse_windows_os_str, 'Windows 2000 Advanced Server')
          result['os.product'].should == 'Windows Server 2000'
        end

        it 'should be recognized for Windows 7' do
          result = host.send(:parse_windows_os_str, 'Windows 7')
          result['os.product'].should == 'Windows 7'
        end

        it 'should be recognized for Windows 7 Ultimate Edition' do
          result = host.send(:parse_windows_os_str, 'Windows 7 Ultimate Edition')
          result['os.product'].should == 'Windows 7'
          result['os.edition'].should == 'Ultimate'
        end

        it 'should be recognized for Windows 8' do
          result = host.send(:parse_windows_os_str, 'Windows 8')
          result['os.product'].should == 'Windows 8'
        end

        it 'should be recognized for Windows 8.1' do
          result = host.send(:parse_windows_os_str, 'Windows 8.1')
          result['os.product'].should == 'Windows 8.1'
        end

        it 'should be recognized for Windows 8.2' do
          result = host.send(:parse_windows_os_str, 'Windows 8.2')
          result['os.product'].should == 'Windows 8.2'
        end

        it 'should be recognized as Windows XP, Build 2600, SP3' do
          result = host.send(:parse_windows_os_str, 'Windows XP (Build 2600, Service Pack 3).')
          result['os.product'].should == 'Windows XP'
          result['os.build'].should == '2600'
          result['os.version'].should == 'SP3'
        end

        it 'should be recognized as Windows Server 2003, Build 3790' do
          result = host.send(:parse_windows_os_str, 'Windows .NET Server (Build 3790).')
          result['os.product'].should == 'Windows Server 2003'
          result['os.build'].should == '3790'
        end

        it 'should be recognized as Windows Server 2008, Build 6001, SP1' do
          result = host.send(:parse_windows_os_str, 'Windows 2008 (Build 6001, Service Pack 1).')
          result['os.product'].should == 'Windows Server 2008'
          result['os.build'].should == '6001'
          result['os.version'].should == 'SP1'
        end

        it 'should default to Windows <name> if all else fails' do
            result = host.send(:parse_windows_os_str, 'Windows Foobar Service Pack 3')
            result['os.product'].should == 'Windows Foobar'
            result['os.version'].should == 'SP3'
        end
      end
    end

    context '#validate_fingerprint_data' do
      before(:each) do
        host.stub(:dlog)
      end

      it 'should return false for an empty hash' do
        fingerprint= FactoryGirl.build(:mdm_note, :data => {})
        host.validate_fingerprint_data(fingerprint).should == false
      end

      it 'should return false for postgresql fingerprints' do
        fingerprint= FactoryGirl.build(:mdm_note, :ntype => 'postgresql.fingerprint', :data => {})
        host.validate_fingerprint_data(fingerprint).should == false
      end

      it 'should return false if the fingerprint does not contain a hash' do
        fingerprint= FactoryGirl.build(:mdm_note, :data => 'this is not a fingerprint')
        host.validate_fingerprint_data(fingerprint).should == false
      end
    end


    context '#apply_match_to_host' do

      before(:each) do
        stub_const('Rex::Text', Module.new)
        allow(Rex::Text).to receive(:ascii_safe_hex) do |unsanitized|
          # Pass back the sanitized value for the stub
          unsanitized.unpack("C*").pack("C*").gsub(/([\x00-\x08\x0b\x0c\x0e-\x1f\x80-\xFF])/n){ |x| "\\x%.2x" % x.unpack("C*")[0]}
        end
      end

      it 'should set host.mac when host.mac is present' do
        match = { 'host.mac' => '00:11:22:33:44:55' }
        host.send(:apply_match_to_host, match)
        host.mac.should == '00:11:22:33:44:55'
      end

      it 'should set host.name when host.name is present' do
        match = { 'host.name' => 'webbyweb' }
        host.send(:apply_match_to_host, match)
        host.name.should == 'webbyweb'
      end

      it 'should set host.arch when os.arch is present' do
        match = { 'os.arch' => 'x86' }
        host.send(:apply_match_to_host, match)
        host.arch.should == 'x86'
      end

      it 'should set host.name to an escaped hex value when host.name contains high bytes' do
        match = { 'host.name' => "HighBytes\xff\xf0".force_encoding('binary') }
        host.send(:apply_match_to_host, match)
        host.name.should == "HighBytes\\xff\\xf0"
      end

      it 'should set host.purpose to client when os.product is Windows XP' do
        match = { 'os.product' => 'Windows XP' }
        host.send(:apply_match_to_host, match)
        host.os_name.should == 'Windows XP'
        host.purpose.should == 'client'
      end

      it 'should set host.purpose to server when os.product is Windows 2012' do
        match = { 'os.product' => 'Windows 2012' }
        host.send(:apply_match_to_host, match)
        host.os_name.should == 'Windows 2012'
        host.purpose.should == 'server'
      end

      it 'should set host.purpose to printer when os.device is Print server' do
        match = { 'os.device' => 'Print server' }
        host.send(:apply_match_to_host, match)
        host.purpose.should == 'printer'
      end

      it 'should set host.os_lang to English when os.language is English' do
        match = { 'os.language' => 'English' }
        host.send(:apply_match_to_host, match)
        host.os_lang.should == 'English'
      end

      it 'should set host.os_name to Windows 8.1 when os.product is Windows 8.1' do
        match = { 'os.product' => 'Windows 8.1' }
        host.send(:apply_match_to_host, match)
        host.os_name.should == 'Windows 8.1'
      end

      it 'should set host.os_name to Windows when os.product is not set and os.family is Windows' do
        match = { 'os.family' => 'Windows' }
        host.send(:apply_match_to_host, match)
        host.os_name.should == 'Windows'
      end

      it 'should set host.os_flavor to Professional when os.edition is Professional' do
        match = { 'os.edition' => 'Professional' }
        host.send(:apply_match_to_host, match)
        host.os_flavor.should == 'Professional'
      end

      it 'should set host.os_sp to SP2 when os.version is SP2' do
        match = { 'os.version' => 'SP2' }
        host.send(:apply_match_to_host, match)
        host.os_sp.should == 'SP2'
      end

      it 'should set host.os_sp to 3.2.11 when os.version is nil and linux.kernel.version is 3.2.11' do
        match = { 'linux.kernel.version' => '3.2.11' }
        host.send(:apply_match_to_host, match)
        host.os_sp.should == '3.2.11'
      end
    end

    context '#normalize_match' do

      it 'should convert Service Pack X to SPX' do
        match = { 'os.version' => 'Service Pack 2' }
        result = host.send(:normalize_match, match)
        result['os.version'].should == 'SP2'
      end

      it 'should not convert No Service Pack to SP' do
        match = { 'os.version' => 'No Service Pack' }
        result = host.send(:normalize_match, match)
        result['os.version'].should == 'No Service Pack'
      end

      it 'should convert Apple Mac OS X to Mac OS X' do
        match = { 'os.product' => 'Apple Mac OS X' }
        result = host.send(:normalize_match, match)
        result['os.product'].should == 'Mac OS X'
        result['os.vendor'].should == 'Apple'
      end

      it 'should convert Microsoft Windows to Windows' do
        match = { 'os.product' => 'Microsoft Windows 7' }
        result = host.send(:normalize_match, match)
        result['os.product'].should == 'Windows 7'
        result['os.vendor'].should == 'Microsoft'
      end

      it 'should convert Windows Server 2012 to Windows 2012' do
        match = { 'os.product' => 'Windows Server 2012' }
        result = host.send(:normalize_match, match)
        result['os.product'].should == 'Windows 2012'
      end
    end

    context '#guess_purpose_from_match' do

      it 'should detect Windows XP as a client' do
        match = { 'os.product' => 'Windows XP' }
        result = host.send(:guess_purpose_from_match, match)
        result.should == 'client'
      end

      it 'should detect Windows 8.1 as a client' do
        match = { 'os.product' => 'Windows 8.1' }
        result = host.send(:guess_purpose_from_match, match)
        result.should == 'client'
      end

      it 'should detect Windows 2000 as a server' do
        match = { 'os.product' => 'Windows 2000' }
        result = host.send(:guess_purpose_from_match, match)
        result.should == 'server'
      end

      it 'should detect Windows Server 2012 as a server' do
        match = { 'os.product' => 'Windows Server 2012' }
        result = host.send(:guess_purpose_from_match, match)
        result.should == 'server'
      end

      it 'should detect Linux as a server' do
        match = { 'os.product' => 'Linux' }
        result = host.send(:guess_purpose_from_match, match)
        result.should == 'server'
      end

      it 'should detect JetDirect as a printer' do
        match = { 'os.product' => 'JetDirect', 'os.device' => 'Print server' }
        result = host.send(:guess_purpose_from_match, match)
        result.should == 'printer'
      end

      it 'should detect Unknown Printer as a printer' do
        match = { 'os.product' => 'Unknown Printer' }
        result = host.send(:guess_purpose_from_match, match)
        result.should == 'printer'
      end

      it 'should detect Linksys Router as a router' do
        match = { 'os.product' => 'Linksys', 'os.device' => 'Router' }
        result = host.send(:guess_purpose_from_match, match)
        result.should == 'router'
      end

      it 'should detect CheckPoint Firewall-1 as a firewall' do
        match = { 'os.vendor' => 'Check Point', 'os.product' => 'Firewall-1' }
        result = host.send(:guess_purpose_from_match, match)
        result.should == 'firewall'
      end
    end

    context '#normalize_scanner_fp' do
      context 'for session_fingerprint' do
        it 'should return all the correct data for Windows XP SP3 x86' do
          fingerprint = FactoryGirl.build(:mdm_session_fingerprint, :host => host)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should == 'Windows XP'
          result['os.version'].should == 'SP3'
          result['os.arch'].should == 'x86'
          result['host.name'].should == nil
          result['os.certainty'].to_f.should == 0.8
        end

        it 'should return all the correct data for Windows 2008 SP1 x64' do
          fp_data = { :os => 'Microsoft Windows 2008 SP1', :arch => 'x64'}
          fingerprint = FactoryGirl.build(:mdm_session_fingerprint, :host => host, :data => fp_data)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should == 'Windows Server 2008'
          result['os.version'].should == 'SP1'
          result['os.arch'].should == 'x64'
          result['host.name'].should == nil
          result['os.certainty'].to_f.should == 0.8
        end

        it 'should fingerprint Metasploitable correctly' do
          # Taken from an actual session_fingerprint of Metasploitable 2
          fp_data = { :os => 'Linux 2.6.24-16-server (i386)', :name => 'metasploitable'}
          fingerprint = FactoryGirl.build(:mdm_session_fingerprint, :host => host, :data => fp_data)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should == 'Linux'
          result['host.name'].should == 'metasploitable'
          result['os.version'].should == '2.6.24-16-server'
          result['os.arch'].should == 'x86'
          result['os.certainty'].to_f.should == 0.8
        end

        it 'should just populate os_name if it is unsure' do
          fp_data = { :os => 'Darwin 12.3.0 x86_64 i386'}
          fingerprint = FactoryGirl.build(:mdm_session_fingerprint, :host => host, :data => fp_data)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should == 'Darwin 12.3.0 x86_64 i386'
          result['os.version'].should == nil
          result['os.arch'].should == nil
          result['os.certainty'].should == 0.8
        end
      end

      context 'for nmap_fingerprint' do
        it 'should return OS name for a Windows XP fingerprint' do
          fingerprint = FactoryGirl.build(:mdm_nmap_fingerprint, :host => host)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should == 'Windows XP'
          result['os.certainty'].to_f.should == described_class::MAX_NMAP_CERTAINTY
        end

        it 'should return OS name for a Metasploitable fingerprint' do
          fp_data = {:os_vendor=>"Linux", :os_family=>"Linux", :os_version=>"2.6.X", :os_accuracy=>100}
          fingerprint = FactoryGirl.build(:mdm_nmap_fingerprint, :host => host, :data => fp_data)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should == 'Linux'
          result['os.version'].should == '2.6.X'
          result['os.certainty'].to_f.should == described_class::MAX_NMAP_CERTAINTY
        end

        it 'should return OS name and flavor fo an OSX fingerprint' do
          fp_data = {:os_vendor=>"Apple", :os_family=>"Mac OS X", :os_version=>"10.8.X", :os_accuracy=>100}
          fingerprint = FactoryGirl.build(:mdm_nmap_fingerprint, :host => host, :data => fp_data)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should == 'Mac OS X'
          result['os.vendor'].should == 'Apple'
          result['os.version'].should == '10.8.X'
          result['os.certainty'].to_f.should == described_class::MAX_NMAP_CERTAINTY
        end
      end

      context 'for nexpose_fingerprint' do
        context 'of a Windows system' do
          it 'should return a generic Windows fingerprint with no product info' do
            fingerprint = FactoryGirl.build(:mdm_nexpose_fingerprint, :host => host)
            result = host.send(:normalize_scanner_fp, fingerprint).first
            result['os.product'].should == 'Windows'
            result['os.arch'].should == 'x86'
            result['os.certainty'].to_f.should == 0.67
          end

          it 'should recognize a Windows 7 fingerprint' do
            fp_data = {:family=>"Windows", :certainty=>"0.67", :vendor=>"Microsoft", :arch=>"x86", :product => 'Windows 7', :version => 'SP1'}
            fingerprint = FactoryGirl.build(:mdm_nexpose_fingerprint, :host => host, :data => fp_data)
            result = host.send(:normalize_scanner_fp, fingerprint).first
            result['os.product'].should == 'Windows 7'
            result['os.version'].should == 'SP1'
            result['os.arch'].should == 'x86'
            result['os.certainty'].to_f.should == 0.67
          end
        end

        it 'should recognize an OSX fingerprint' do
          fp_data = {:family=>"Mac OS X", :certainty=>"0.80", :vendor=>"Apple"}
          fingerprint = FactoryGirl.build(:mdm_nexpose_fingerprint, :host => host, :data => fp_data)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should == 'Mac OS X'
          result['os.vendor'].should == "Apple"
        end

        it 'should recognize a Cisco fingerprint' do
          fp_data = {:family=>"IOS", :certainty=>"1.00", :vendor=>"Cisco", :version=>"11.2(8)SA2"}
          fingerprint = FactoryGirl.build(:mdm_nexpose_fingerprint, :host => host, :data => fp_data)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should == 'IOS'
          result['os.vendor'].should == 'Cisco'
        end

        it 'should recognize an embedded fingerprint' do
          fp_data = {:family=>"embedded", :certainty=>"1.00", :vendor=>"Footek"}
          fingerprint = FactoryGirl.build(:mdm_nexpose_fingerprint, :host => host, :data => fp_data)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should == 'Footek'
        end

        it 'should handle an unknown fingerprint' do
          fp_data = {:certainty=>"1.00", :vendor=>"Footek"}
          fingerprint = FactoryGirl.build(:mdm_nexpose_fingerprint, :host => host, :data => fp_data)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should == 'Footek'
        end


      end

      context 'for retina_fingerprint' do
        it 'should recognize a Windows fingerprint' do
          fingerprint = FactoryGirl.build(:mdm_retina_fingerprint, :host => host)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should ==  'Windows Server 2003'
          result['os.arch'].should == 'x64'
          result['os.version'].should == 'SP2'
          result['os.certainty'].to_f.should == 0.8
        end

        it 'should otherwise jsut copy the fingerprint to os_name' do
          fp_data = { :os => 'Linux 2.6.X (i386)'}
          fingerprint = FactoryGirl.build(:mdm_retina_fingerprint, :host => host, :data => fp_data)
          result = host.send(:normalize_scanner_fp, fingerprint).first
          result['os.product'].should ==  'Linux 2.6.X (i386)'
          result['os.certainty'].to_f.should == 0.8
        end
      end
    end

  end

  context 'search' do
    let(:base_class) {
      described_class
    }

    context 'attributes' do

      it_should_behave_like 'search_with',
                            MetasploitDataModels::Search::Operator::IPAddress,
                            name: :address
      it_should_behave_like 'search_attribute',
                            :name,
                            type: :string
      it_should_behave_like 'search_with',
                            MetasploitDataModels::Search::Operator::Multitext,
                            name: :os,
                            operator_names: [
                              :os_name,
                              :os_flavor,
                              :os_sp
                            ]
      it_should_behave_like 'search_attribute',
                            :os_name,
                            type: :string
    end
  end
end
