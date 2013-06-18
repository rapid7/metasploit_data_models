require 'spec_helper'

describe Mdm::Authority::Cve do
  context 'designation_url' do
    subject(:designation_url) do
      described_class.designation_url(designation)
    end

    let(:designation) do
      FactoryGirl.generate :mdm_reference_cve_designation
    end

    it 'should be under cve directory' do
      designation_url.should == "http://cvedetails.com/cve/CVE-#{designation}"
    end
  end
end