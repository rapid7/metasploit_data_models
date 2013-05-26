require 'spec_helper'

describe Mdm::Service do

  context "Associations" do

    it { should have_many(:task_services).class_name('Mdm::TaskService').dependent(:destroy) }
    it { should have_many(:tasks).class_name('Mdm::Task').through(:task_services) }
    it { should have_many(:creds).class_name('Mdm::Cred').dependent(:destroy) }
    it { should have_many(:exploited_hosts).class_name('Mdm::ExploitedHost').dependent(:destroy) }
    it { should have_many(:notes).class_name('Mdm::Note').dependent(:destroy) }
    it { should have_many(:vulns).class_name('Mdm::Vuln').dependent(:destroy) }
    it { should have_many(:web_sites).class_name('Mdm::WebSite').dependent(:destroy) }
    it { should have_many(:web_pages).class_name('Mdm::WebPage').through(:web_sites) }
    it { should have_many(:web_forms).class_name('Mdm::WebForm').through(:web_sites) }
    it { should have_many(:web_vulns).class_name('Mdm::WebVuln').through(:web_sites) }
    it { should belong_to(:host).class_name('Mdm::Host') }
  end

  context 'scopes' do
    context "inactive" do
      it "should exclude open services" do
        open_service = FactoryGirl.create(:mdm_service, :state => 'open')
        Mdm::Service.inactive.should_not include(open_service)
      end
    end

    context "with_state open" do
      it "should exclude closed services" do
        closed_service = FactoryGirl.create(:mdm_service, :state => 'closed')
        Mdm::Service.with_state('open').should_not include(closed_service)
      end
    end

    context "search for 'snmp'" do
      it "should find only services that match" do
        snmp_service   = FactoryGirl.create(:mdm_service)
        ftp_service    =  FactoryGirl.create(:mdm_service, :proto => 'ftp')
        search_results = Mdm::Service.search('snmp')
        search_results.should     include(snmp_service)
        search_results.should_not include(ftp_service)
      end
    end
  end

  context 'callbacks' do
    context 'after_save' do
      it 'should call #normalize_host_os' do
        svc = FactoryGirl.create(:mdm_service)
        svc.should_receive(:normalize_host_os)
        svc.run_callbacks(:save)
      end
    end
  end

end