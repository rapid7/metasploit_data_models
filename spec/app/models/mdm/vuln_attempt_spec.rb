require 'spec_helper'

describe Mdm::VulnAttempt do
  it_should_behave_like 'Metasploit::Concern.run'

  context 'association' do
    it { should belong_to(:vuln).class_name('Mdm::Vuln') }
  end

  context 'database' do

    context 'timestamps'do
      it { should have_db_column(:attempted_at).of_type(:datetime) }
    end

    context 'columns' do
      it { should have_db_column(:vuln_id).of_type(:integer) }
      it { should have_db_column(:exploited).of_type(:boolean) }
      it { should have_db_column(:fail_reason).of_type(:string) }
      it { should have_db_column(:username).of_type(:string) }
      it { should have_db_column(:module).of_type(:text) }
      it { should have_db_column(:session_id).of_type(:integer) }
      it { should have_db_column(:loot_id).of_type(:integer) }
      it { should have_db_column(:fail_detail).of_type(:text) }
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
      vuln_attempt = FactoryGirl.build(:mdm_vuln_attempt)
      vuln_attempt.should be_valid
    end
  end

  context '#destroy' do
    it 'should successfully destroy the object' do
      vuln_attempt = FactoryGirl.create(:mdm_vuln_attempt)
      expect {
        vuln_attempt.destroy
      }.to_not raise_error
      expect {
        vuln_attempt.reload
      }.to raise_error(ActiveRecord::RecordNotFound)
    end
  end

end