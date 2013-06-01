require 'spec_helper'

describe Mdm::VulnDetail do

  context 'association' do
    it { should belong_to(:vuln).class_name('Mdm::Vuln') }
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:nx_published).of_type(:datetime) }
      it { should have_db_column(:nx_added).of_type(:datetime) }
      it { should have_db_column(:nx_modified).of_type(:datetime) }
      it { should have_db_column(:nx_vulnerable_since).of_type(:datetime) }
    end

    context 'columns' do
      it { should have_db_column(:vuln_id).of_type(:integer)}
      it { should have_db_column(:cvss_score).of_type(:float) }
      it { should have_db_column(:cvss_vector).of_type(:string) }
      it { should have_db_column(:title).of_type(:string) }
      it { should have_db_column(:description).of_type(:text) }
      it { should have_db_column(:solution).of_type(:text) }
      it { should have_db_column(:proof).of_type(:binary) }
      it { should have_db_column(:nx_console_id).of_type(:integer) }
      it { should have_db_column(:nx_device_id).of_type(:integer) }
      it { should have_db_column(:nx_severity).of_type(:float) }
      it { should have_db_column(:nx_pci_severity).of_type(:float) }
      it { should have_db_column(:nx_tags).of_type(:text) }
      it { should have_db_column(:nx_vuln_status).of_type(:text) }
      it { should have_db_column(:nx_proof_key).of_type(:text) }
      it { should have_db_column(:src).of_type(:string) }
      it { should have_db_column(:nx_scan_id).of_type(:integer) }
      it { should have_db_column(:nx_pci_compliance_status).of_type(:string) }
    end
  end

  context 'validations' do
    it 'should require a vuln_id' do
      orphan_detail = FactoryGirl.build(:mdm_vuln_detail, :vuln => nil)
      orphan_detail.should_not be_valid
      orphan_detail.errors[:vuln_id].should include("can't be blank")
    end
  end

  context 'factory' do
    it 'should be valid' do
      vuln_detail = FactoryGirl.build(:mdm_vuln_detail)
      vuln_detail.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      vuln_detail = FactoryGirl.create(:mdm_vuln_detail)
      expect {
        vuln_detail.destroy
      }.to_not raise_error
      expect {
        vuln_detail.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end
