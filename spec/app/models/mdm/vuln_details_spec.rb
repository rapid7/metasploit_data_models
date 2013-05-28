require 'spec_helper'

describe Mdm::VulnDetail do

  context 'association' do
    it { should belong_to(:vuln).class_name('Mdm::Vuln') }
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
