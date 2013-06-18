require 'spec_helper'

describe Mdm::Authority::Msb do
  context 'designation_url' do
    subject(:designation_url) do
      described_class.designation_url(designation)
    end

    let(:designation) do
      FactoryGirl.generate :mdm_reference_msb_designation
    end

    it 'should be under security bulletins' do
      designation_url.should == "http://www.microsoft.com/technet/security/bulletin/#{designation}"
    end
  end
end