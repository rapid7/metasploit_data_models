require 'spec_helper'

describe Mdm::Authority::UsCertVu do
  context 'designation_url' do
    subject(:designation_url) do
      described_class.designation_url(designation)
    end

    let(:designation) do
      FactoryGirl.generate :mdm_reference_us_cert_vu_designation
    end

    it 'should be under bid directory' do
      designation_url.should == "http://www.kb.cert.org/vuls/id/#{designation}"
    end
  end
end