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

  context 'factory' do
    it 'should be valid' do
      service = FactoryGirl.build(:mdm_service)
      service.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      service = FactoryGirl.create(:mdm_service)
      expect {
        service.destroy
      }.to_not raise_error
      expect {
        service.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:created_at).of_type(:datetime) }
      it { should have_db_column(:updated_at).of_type(:datetime) }
    end

    context 'columns' do
      it { should have_db_column(:host_id).of_type(:integer) }
      it { should have_db_column(:port).of_type(:integer).with_options(:null => false) }
      it { should have_db_column(:proto).of_type(:string).with_options(:null => false) }
      it { should have_db_column(:state).of_type(:string) }
      it { should have_db_column(:name).of_type(:string) }
      it { should have_db_column(:info).of_type(:text) }
    end

    context 'indices' do
      it { should have_db_index(:name) }
      it { should have_db_index(:port) }
      it { should have_db_index(:proto) }
      it { should have_db_index(:state) }
    end
  end

  context "validations" do
    let(:mdm_service) do
      mdm_service = FactoryGirl.build(:mdm_service)
      mdm_service.valid?
      mdm_service
    end

    context "invalid" do
      it "should validate presence of :port" do
        mdm_service.port = nil
        mdm_service.valid?
        mdm_service.errors[:port][0].should include "is not a number"
      end

      it "should validate presence of :proto" do
        mdm_service.proto = nil
        mdm_service.valid?
        mdm_service.errors[:proto][0].should include "can't be blank"
      end

      it "should not allow non-numeric value for port" do
        mdm_service.port = Faker::Lorem.characters(4)
        mdm_service.valid?
        mdm_service.errors[:port][0].should include "is not a number"
      end
    end

    context "valid" do
      it "should allow numeric value for port" do
        mdm_service.port = Faker::Number.number(4)
        mdm_service.valid?
        mdm_service.should have(0).errors_on(:port)
      end

      it "should allow proto" do
        mdm_service.proto = "tcp"
        mdm_service.valid?
        mdm_service.should have(0).errors_on(:proto)
      end
    end
  end
end