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
        'x86_64'
    ]
  end

  let(:operating_system_names) do
    [
        'FreeBSD',
        'Linux',
        'Mac OS X',
        'Microsoft Windows',
        'NetBSD',
        'OpenBSD',
        'Unknown',
        'VMWare'
    ]
  end

  let(:states) do
    [
        'alive',
        'down',
        'unknown'
    ]
  end

	context 'associations' do
    it { should have_many(:creds).class_name('Mdm::Cred').through(:services) }
		it { should have_many(:exploit_attempts).class_name('Mdm::ExploitAttempt').dependent(:destroy) }
		it { should have_many(:exploited_hosts).class_name('Mdm::ExploitedHost').dependent(:destroy) }
    it { should have_many(:host_details).class_name('Mdm::HostDetail').dependent(:destroy) }
    it { should have_many(:hosts_tags).class_name('Mdm::HostTag') }
    it { should have_many(:loots).class_name('Mdm::Loot').dependent(:destroy).order('loots.created_at DESC') }

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
                  host.module_details.should =~ [module_detail]
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

	context 'callbacks' do
    context 'before destroy' do
      context 'cleanup_tags' do
        context 'with tags' do
          let!(:tag) do
            FactoryGirl.create(:mdm_tag)
          end

          let!(:host) do
            FactoryGirl.create(:mdm_host)
          end

          context 'with only this host' do
            before(:each) do
              FactoryGirl.create(
                  :mdm_host_tag,
                  :host => host,
                  :tag => tag
              )
            end

            it 'should destroy the tags' do
              expect {
                host.destroy
              }.to change(Mdm::Tag, :count).by(-1)
            end

            it 'should destroy the host tags' do
              expect {
                host.destroy
              }.to change(Mdm::HostTag, :count).by(-1)
            end
          end

          context 'with additional hosts' do
            let(:other_host) do
              FactoryGirl.create(:mdm_host)
            end

            before(:each) do
              FactoryGirl.create(:mdm_host_tag, :host => host, :tag => tag)
              FactoryGirl.create(:mdm_host_tag, :host => other_host, :tag => tag)
            end

            it 'should not destroy the tag' do
              expect {
                host.destroy
              }.to_not change(Mdm::Tag, :count)
            end

            it 'should destroy the host tags' do
              expect {
                host.destroy
              }.to change(Mdm::HostTag, :count).by(-1)
            end

            it "should not destroy the other host's tags" do
              host.destroy

              other_host.hosts_tags.count.should == 1
            end
          end
        end
      end
    end
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
    end

    it 'should define OPERATING_SYSTEM_NAMES in any order' do
      described_class::OPERATING_SYSTEM_NAMES.should =~ operating_system_names
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

  context 'validations' do
    it { should ensure_inclusion_of(:arch).in_array(architectures).allow_nil }
    it { should ensure_inclusion_of(:state).in_array(states).allow_nil }
  end
end