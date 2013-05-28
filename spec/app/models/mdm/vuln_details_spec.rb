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

end
