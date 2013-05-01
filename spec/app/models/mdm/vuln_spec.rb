require 'spec_helper'

describe Mdm::Vuln do
  context 'factories' do
    context 'mdm_vuln' do
      subject(:mdm_vuln) do
        FactoryGirl.build(:mdm_vuln)
      end

      it { should be_valid }
    end
  end
end