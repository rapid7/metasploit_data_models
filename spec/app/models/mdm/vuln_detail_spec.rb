require 'spec_helper'

describe Mdm::VulnDetail do
  context 'associations' do
    it { should belong_to(:nexpose_console).class_name('Mdm::NexposeConsole').with_foreign_key(:nx_console_id) }
    it { should belong_to(:vuln).class_name('Mdm::Vuln') }
  end

  context 'database' do
    context 'columns' do
      it { should have_db_column(:description).of_type(:text) }
      it { should have_db_column(:proof).of_type(:binary) }
      it { should have_db_column(:solution).of_type(:text) }
      it { should have_db_column(:src).of_type(:string) }
      it { should have_db_column(:title).of_type(:string) }
      it { should have_db_column(:vuln_id).of_type(:integer) }

      context 'cvss' do
        it { should have_db_column(:cvss_score).of_type(:float) }
        it { should have_db_column(:cvss_vector).of_type(:string) }
      end

      context 'nexpose' do
        it { should have_db_column(:nx_added).of_type(:datetime) }
        it { should have_db_column(:nx_console_id).of_type(:integer) }
        it { should have_db_column(:nx_device_id).of_type(:integer) }
        it { should have_db_column(:nx_modified).of_type(:datetime) }
        it { should have_db_column(:nx_proof_key).of_type(:text) }
        it { should have_db_column(:nx_published).of_type(:datetime) }
        it { should have_db_column(:nx_scan_id).of_type(:integer) }
        it { should have_db_column(:nx_severity).of_type(:float) }
        it { should have_db_column(:nx_tags).of_type(:text) }
        it { should have_db_column(:nx_vuln_id).of_type(:string) }
        it { should have_db_column(:nx_vuln_status).of_type(:text) }
        it { should have_db_column(:nx_vulnerable_since).of_type(:datetime) }

        context 'pci' do
          it { should have_db_column(:nx_pci_compliance_status).of_type(:string) }
          it { should have_db_column(:nx_pci_severity).of_type(:float) }
        end
      end
    end
  end

  context 'factories' do
    context 'mdm_vuln_detail' do
      subject(:mdm_vuln_detail) do
        FactoryGirl.build(:mdm_vuln_detail)
      end

      it { should be_valid }
    end
  end

  context 'validations' do
    it { should validate_presence_of :vuln_id }
  end
end