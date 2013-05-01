require 'spec_helper'

describe Mdm::VulnRef do
  context 'factories' do
    context 'mdm_vuln_ref' do
      subject(:mdm_vuln_ref) do
        FactoryGirl.build(:mdm_vuln_ref)
      end

      it { should be_valid }
    end
  end
end