require 'spec_helper'

describe Mdm::VulnAttempt do
  subject(:vuln_attempt) do
    described_class.new
  end

  it_should_behave_like 'Mdm::Attempt' do
    subject(:attempt) do
      vuln_attempt
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